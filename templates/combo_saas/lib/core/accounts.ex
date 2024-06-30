defmodule ComboSaaS.Core.Accounts do
  @moduledoc """
  The context for accounts.

  ## Features

    * register users
    * change users' email
    * change users' password
    * reset users' password
    * manage users' session tokens

  ## Design Spec

  ### No authentication framework.

  Authentication frameworks encapsulate most of the authentication complexity.
  But, to make them flexible and general purpose, it's very hard to not make
  them complex. A complex codebase is harder to be audited, which is important
  in authentication systems.

  And, when customization is required, the encapsulation provided by authentication
  frameworks will become a burden - it could be difficult to understand how them
  works, making it hard to make changes in a short period of time.

  Because of that, this context implements a simple and straight-forward
  authentication system, without relying on any authentication frameworks.

  Everyone has complete freedom to modify this authentication system so it
  works best with their app.

  ### Emails

  The email lookup is made to be case insensitive.

  ### Tokens

  Hashed tokens are stored in separated tables, the original tokens are not
  stored.

  It prevent unauthorized usage of the tokens.

  ### Notifiers

  The authentication system ships with an email notifier. But, it's free to
  implement your own notifiers, such as an SMS notifier, etc.

  ### Password hashing

  The chosen password hashing algorithm is Argon2.

  Argon2 is a memory-based hash algorithm designed to prevent large-scale
  parallel attacks (such as those using GPUs), offering stronger security,
  especially against more powerful attack methods.

  Argon2 provides configurable memory, time complexity, suitable for scenarios
  with varying security needs, making it a modern, customizable choice for
  password storage and verification.

  ### Session Tracking

  Phoenix provides session support, but the default session cookies are not
  persisted,they are simply signed and potentially encrypted. This means they
  are valid indefinitely, unless you change the siging/encryption salt.

  To address above drawbacks, sessions are tracked as tokens. It allows to
  manage sessions in a more refined manner, such as:

    * expire existing sessions.
    * track how many sessions are active for each account.
    * track devices used for logging in.
    * ...

  You could even expose the session information to users if desired, such as
  displaying all valid sessions and devices in UI and allow users to explicitly
  expire any session they deem invalid.

  ### The confirmation of operations

  The authentication system ships with an confirmation mechanism, where users
  have to confirm their operations with tokens, which are sent by the email
  notifier by default.

  ### Integrations with plugs

    * `fetch_current_user` - fetches the current user information if available.
    * `require_authenticated_user` - must be invoked after fetch_current_user and requires that a current user exists and is authenticated.
    * `redirect_if_user_is_authenticated` - used for the few pages that must not be available to authenticated users.

  ## Security Considerations

  ### User Enumeration attacks

  A user enumeration attack allows an attacker to enumerate all emails registered
  in the system. For example, if trying to log in with a registered email and a
  wrong password returns a different error than trying to log in with an email
  that was never registered, an attacker could use this discrepency to find out
  which emails are registered.

  The authentication system protects against enumeration attacks on all
  endpoints, except in the registration and update email forms. If your system
  is really sensitive to enumeration attacks, you need to implement your own
  registration workflow, which tends to be very different from the workflow for
  most applications.

  ## References

    * [An upcoming authentication solution for Phoenix](https://dashbit.co/blog/a-new-authentication-solution-for-phoenix)
    * [Original design spec of `mix phx.gen.auth`](https://github.com/dashbitco/mix_phx_gen_auth_demo/blob/auth/README.md)
    * [Original pull request of `mix phx.gen.auth`](https://github.com/dashbitco/mix_phx_gen_auth_demo/pull/1)
    * [Original package of `mix phx.gen.auth`](https://github.com/aaronrenner/phx_gen_auth)

  """

  import ComboSaaS.Toolkit.EasyFlow
  alias ComboSaaS.Core.Repo
  alias ComboSaaS.Core.Accounts.User
  alias ComboSaaS.Core.Accounts.Users
  alias ComboSaaS.Core.Accounts.NoUserTokens
  alias ComboSaaS.Core.Accounts.UserTokens
  alias ComboSaaS.Core.Accounts.UserSessionTokens

  @doc """
  Gets a user.
  """
  defdelegate get_user!(id), to: Users

  @doc """
  Gets a user by email.
  """
  defdelegate get_user_by_email(email), to: Users

  @doc """
  Gets a user by email and password.
  """
  defdelegate get_user_by_email_and_password(email, password), to: Users

  @doc """
  Sends a registration token to an email.

  ## Notes

    * Multiple different tokens can be sent to the same email.
    * To prevent spamming registered users, a token is only generated and sent
      when the email isn't taken.
    * To prevent user enumeration attacks, when the email is in valid format,
      this function will always return `:ok` even if the email has been taken.

  """
  @spec send_user_registration_token(Users.email()) ::
          :ok | {:error, Ecto.Changeset.t()}
  def send_user_registration_token(email) do
    with {:ok, email} <- Users.validate_email(email) do
      unless Users.get_user_by_email(email) do
        Repo.transact(fn ->
          token = NoUserTokens.create_token(email, :register)
          # TODO: enqueue sending the token
          {:ok, IO.inspect(token)}
        end)
      end

      :ok
    end
  end

  @doc """
  Registers a user.

  ## Notes

    * All registration tokens sent to the email will be deleted after the
      corresponding user is created.

  """
  @spec register_user(Users.email(), NoUserTokens.token(), Users.password()) ::
          {:ok, User.t()} | {:error, :invalid_token | Ecto.Changeset.t()}
  def register_user(email, token, password) do
    Repo.transact(fn ->
      with :ok <- ok_else(NoUserTokens.consume_token(email, :register, token), :invalid_token),
           {:ok, user} <- Users.create_user(email, password),
           :ok <- NoUserTokens.delete_tokens(email, :register) do
        {:ok, user}
      end
    end)
  end

  @doc """
  Sends an email_change token to a user's email.

  ## Notes

    * Multiple different tokens can be sent to the same email.
    * The user's email has been validated when registering user, changing email
      and so on, so it's unnecessary to validate it again.

  """
  @spec send_user_email_change_token(User.t()) :: :ok
  def send_user_email_change_token(user) do
    Repo.transact(fn ->
      token = UserTokens.create_token(user, user.email, :email_change)
      # TODO: enqueue sending the token
      {:ok, IO.inspect(token)}

      :ok
    end)
  end

  @doc """
  Sends an email_change token to a user's new email.

  ## Notes

    * Multiple different tokens can be sent to the same email.
    * To prevent spamming registered users, a token is only generated and sent
      when the email isn't taken.
    * To prevent user enumeration attacks, when the email is in valid format,
      this function will always return `:ok` even if the email has been taken.

  """
  @spec send_user_email_change_token_to_new_email(User.t(), Users.email()) ::
          :ok | {:error, Ecto.Changeset.t()}
  def send_user_email_change_token_to_new_email(user, email) do
    with {:ok, email} <- Users.validate_email(email) do
      unless Users.get_user_by_email(email) do
        Repo.transact(fn ->
          token = UserTokens.create_token(user, email, :email_change)
          # TODO: enqueue sending the token
          {:ok, IO.inspect(token)}
        end)
      end

      :ok
    end
  end

  @doc """
  Changes a user's email.

  ## Notes

    * All email_change tokens sent to the user's email and new email will be
      deleted after the email is changed.

  """
  @spec change_user_email(User.t(), UserTokens.token(), Users.email(), UserTokens.token()) ::
          {:ok, User.t()} | {:error, :invalid_token | Ecto.Changeset.t()}
  def change_user_email(user, token, new_email, new_email_token) do
    with {:ok, user} <-
           Repo.transact(fn ->
             with :ok <-
                    ok_else(
                      UserTokens.consume_token(user, user.email, :email_change, token),
                      {:invalid_token, :email}
                    ),
                  :ok <-
                    ok_else(
                      UserTokens.consume_token(user, new_email, :email_change, new_email_token),
                      {:invalid_token, :new_email}
                    ) do
               Users.change_user_email(user, new_email)
             end
           end) do
      UserTokens.delete_tokens(user, user.email, :email_change)
      UserTokens.delete_tokens(user, new_email, :email_change)

      {:ok, user}
    end
  end

  @doc """
  Sends a password_change token to a user's email.

  ## Notes

    * Multiple different tokens can be sent to the same email.
    * The user's email has been validated when registering user, changing email
      and so on, so it's unnecessary to validate it again.

  """
  @spec send_user_password_change_token(User.t()) :: :ok
  def send_user_password_change_token(user) do
    Repo.transact(fn ->
      token = UserTokens.create_token(user, user.email, :password_change)
      # TODO: enqueue sending the token
      {:ok, IO.inspect(token)}

      :ok
    end)
  end

  @doc """
  Changes a user's password.

  ## Notes

    * All password_change tokens sent to the user's email will be deleted
      after the password is changed.

  """
  @spec change_user_password(User.t(), UserTokens.token(), Users.password()) ::
          {:ok, User.t()} | {:error, :invalid_token | Ecto.Changeset.t()}
  def change_user_password(user, token, password) do
    with {:ok, user} <-
           Repo.transact(fn ->
             with :ok <-
                    ok_else(
                      UserTokens.consume_token(user, user.email, :password_change, token),
                      :invalid_token
                    ) do
               Users.change_user_password(user, password)
             end
           end) do
      # Users likely change their passwords to regain the full control of their
      # accounts. Based on this reason, user tokens are deleted for them.
      UserTokens.delete_tokens(user)

      # After the transaction is commited, the password hash is updated. At
      # this point, deleting all session tokens ensures no one can log in
      # successfully with old password.
      UserSessionTokens.delete_tokens(user)

      {:ok, user}
    end
  end

  @doc """
  Sends a password_reset token to an email.

  ## Notes

    * Multiple different tokens can be sent to the same email.
    * To prevent user enumeration attacks, when the email is in valid format,
      this function will always return `:ok` even if the email doesn't exist
      in our system.

  """
  @spec send_user_password_reset_token(Users.email()) ::
          :ok | {:error, Ecto.Changeset.t()}
  def send_user_password_reset_token(email) do
    with {:ok, email} <- Users.validate_email(email) do
      if user = Users.get_user_by_email(email) do
        token = UserTokens.create_token(user, email, :password_reset)
        # TODO: enqueue sending the token
        {:ok, IO.inspect(token)}
      end

      :ok
    end
  end

  @doc """
  Resets a user's password.

  ## Notes

    * To prevent user enumeration attacks, when the email doesn't exist in our
      system, an "invalid token" error instead of an "invalid email" error is
      returned.

  """
  @spec reset_user_password(Users.email(), UserTokens.token(), Users.password()) ::
          {:ok, User.t()} | {:error, :invalid_token | Ecto.Changeset.t()}
  def reset_user_password(email, token, password) do
    with {:ok, user} <-
           Repo.transact(fn ->
             with {:ok, user} <- if_else(Users.get_user_by_email(email), :invalid_token),
                  :ok <-
                    ok_else(
                      UserTokens.consume_token(user, user.email, :password_reset, token),
                      :invalid_token
                    ) do
               Users.change_user_password(user, password)
             end
           end) do
      # Users likely reset their passwords to regain the full control of their
      # accounts. Based on this reason, user tokens are deleted for them.
      UserTokens.delete_tokens(user)

      # After the transaction is commited, the password hash is updated. At
      # this point, deleting all session tokens ensures no one can log in
      # successfully with old password.
      UserSessionTokens.delete_tokens(user)

      {:ok, user}
    end
  end

  @doc """
  Creates a session token.
  """
  @spec create_user_session_token(User.t()) :: UserSessionTokens.token()
  def create_user_session_token(user) do
    UserSessionTokens.create_token(user)
  end

  @doc """
  Gets a user with the a session token.
  """
  @spec get_user_by_session_token(UserSessionTokens.token()) :: User.t() | nil
  def get_user_by_session_token(token) do
    with {:ok, user_session_token} <- UserSessionTokens.fetch_token(token),
         user_session_token = Repo.preload(user_session_token, :user),
         :ok <- if_else(user_session_token.user),
         do: user_session_token.user,
         else: (_ -> nil)
  end

  @doc """
  Deletes the session token.
  """
  @spec delete_user_session_token(UserSessionTokens.token()) :: :ok
  def delete_user_session_token(token) do
    UserSessionTokens.delete_token(token)
  end
end

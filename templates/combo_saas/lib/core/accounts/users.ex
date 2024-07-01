defmodule ComboSaaS.Core.Accounts.Users do
  @moduledoc false

  import Ecto.Changeset
  alias ComboSaaS.Core.Repo
  alias ComboSaaS.Core.Accounts.User

  @type id :: String.t()
  @type email :: String.t()
  @type password :: String.t()

  @spec get_user!(id()) :: User.t()
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @spec get_user_by_email(email()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @spec fetch_user_by_email(email()) :: {:ok, User.t()} | :error
  def fetch_user_by_email(email) when is_binary(email) do
    if user = Repo.get_by(User, email: email),
      do: {:ok, user},
      else: :error
  end

  @spec get_user_by_email_and_password(email(), password()) :: User.t() | nil
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if valid_password?(user, password), do: user
  end

  @spec fetch_user_by_email_and_password(email(), password()) :: {:ok, User.t()} | :error
  def fetch_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    if valid_password?(user, password),
      do: {:ok, user},
      else: :error
  end

  @spec create_user(email(), password()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(email, password) do
    %User{}
    |> changeset(email: email, password: password)
    |> Repo.insert()
  end

  @spec validate_email(email()) :: {:ok, email()} | {:error, Ecto.Changeset.t()}
  def validate_email(email) do
    with {:ok, %User{email: email}} <-
           apply_action(
             changeset(%User{}, [email: email], validate_unique_email: false),
             :validate
           ) do
      {:ok, email}
    end
  end

  @spec change_user_email(User.t(), email()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_user_email(user, email) do
    user
    |> changeset(email: email)
    |> Repo.update()
  end

  @spec change_user_password(User.t(), password()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_user_password(user, password) do
    user
    |> changeset(password: password)
    |> Repo.update()
  end

  # Creates a changeset for changing user.
  #
  # It is important to validate the length of both email and password.
  #
  # Otherwise, databases may truncate the email without warnings, which could lead
  # to unpredictable or insecure behaviour. And, long passwords may also be very
  # expensive to hash for certain algorithms.
  #
  # # Options
  #
  #   * `:validate_unique_email` - Validates the uniqueness of the email, in case
  #     you don't want to validate the uniqueness of the email (like when
  #     using this changeset for validations on a LiveView form before
  #     submitting the form), this option can be set to `false`.
  #     Defaults to `true`.
  #
  #   * `:hash_password` - Hashes the password so it can be stored securely
  #     in the database and ensures the password field is cleared to prevent
  #     leaks in the logs. If password hashing is not needed and clearing the
  #     password field is not desired (like when using this changeset for
  #     validations on a LiveView form before submiting the form), this option
  #     can be set to `false`.
  #     Defaults to `true`.
  #
  defp changeset(%User{} = user, changes, opts \\ []) do
    Enum.reduce(changes, change(user), &change_user(&2, &1, opts))
  end

  # Verifies the password.
  #
  # If there is no user or the user doesn't have a password, we call
  # `Argon2.no_user_verify/0` to avoid timing attacks.
  defp valid_password?(%User{password_hash: password_hash}, password)
       when is_binary(password_hash) and byte_size(password) > 0 do
    Argon2.verify_pass(password, password_hash)
  end

  defp valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end

  # the regex is extracted from https://github.com/maennchen/email_checker
  @email_regex ~S"""
               ^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?<domain>(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\]))$
               """
               |> String.trim()
               |> Regex.compile!([:caseless])
  defp change_user(changeset, {:email, email}, opts) do
    changeset
    |> change(email: email)
    |> validate_required([:email])
    |> validate_format(:email, @email_regex)
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp change_user(changeset, {:password, password}, opts) do
    changeset
    |> change(password: password)
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    validate_unique_email? = Keyword.get(opts, :validate_unique_email, true)

    if validate_unique_email? do
      changeset
      |> unsafe_validate_unique(:email, Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end

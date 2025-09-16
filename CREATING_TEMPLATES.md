# Creating Templates

Rules:

- the OTP application name of a template must be `:my_app`.
- the base module name of a template must be `MyApp`.
- the environment variables used in a template must be prefixed with `MY_APP`.
- `=========================secret_key_base=========================` should be used as the `secret_key_base` placeholder.
- `==signing_salt==` should be used as the `signing_salt` placeholder.

> Why use "my_app" and similar placeholders? Because `combo_new` generates projects from templates using string replacement (this method is primitive but straightforward and quick), and to prevent conflicts with strings users might actually use, I subjectively chose `my_app`, which is short, easily recognizable, and no one uses it in serious code.

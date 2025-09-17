# Creating Templates

Rules:

- the OTP application name of a template must be `:my_app`.
- the base module name of a template must be `MyApp`.
- the environment variables used in a template must be prefixed with `MY_APP`.
- `= random_string(length) =` should be used as the placeholder of random string. For example:
  - `= random_string(20) =`, which generates 20-char random string.
  - `======== random_string(20) ========`, which generates 20-char random string.

> Why use "my_app" and similar placeholders? Because `combo_new` generates projects from templates using string replacement (this method is primitive but straightforward and quick), and to prevent conflicts with strings users might actually use, I subjectively chose `my_app`, which is short, easily recognizable, and no one uses it in serious code.

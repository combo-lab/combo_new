# Creating Templates

Rules:

- the app name of a template must be `:demo_lt`.
- the base module name of a template must be `DemoLT`.
- the environment variables used in a template must be prefixed with `DEMO_LT`.
- `=========================secret_key_base=========================` should be used as the `secret_key_base` placeholder.
- `==signing_salt==` should be used as the `signing_salt` placeholder.

> Why `demo_lt` and similar placeholders? Because `combo_new` generates projects from templates using string replacement (this method is primitive but straightforward and quick), and to prevent conflicts with strings users might actually use, I subjectively chose `demo_lt`, which is an abbreviation for "demo live template".

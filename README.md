# combo_new

An opinionated project generator for Phoenix.

> It's a part of `combo`, which is an opinionated code generator for Phoenix.

## Usage

Install the archive of `combo_new`:

```
$ mix archive.install hex combo_new
```

Create a new Phoenix project:

```
# create a project from combo_lite template
$ mix combo_new.lite demo

# create a project from combo_saas template
$ mix combo_new.saas demo
```

See `mix help` for more details.

## Features

- asset pipeline powered by [esbuild](https://esbuild.github.io/) and Node.js ecosystem
- reduced number of processes running in dev environment, which is derived from [axelson's repo](https://github.com/axelson/hello_phoenix/pull/1)
- liveness probe, which is common in container environments.
- ...

## Sync Status

`combo_new` will continuously track changes in Phoenix and merge them in.

Currently, this repo is synchronized to the commit `6486203`(2024/02/02) of [phoenixframework/phoenix](https://github.com/phoenixframework/phoenix).

## Why?

Previously, I made many attempts at codemod on Phoenix generated files:

- [c4710n/phx_custom](https://github.com/c4710n/phx_custom)
- [c4710n/phoenix_custom_assets](https://github.com/c4710n/phoenix_custom_assets)

But they all require some additional steps after executing `mix phx.new`. There were so many additional steps that I had to do them while referring to a checklist.

I wanted to reduce this mental burden from the root, so I made this project generator.

The project generator includes some templates tailored to my own needs. Since these templates are specially tailored, the project generator doesn't need that many options to meet different people's requirements.

Additionally, all the templates are directly executable projects, which makes development and debugging very simple.

## Thanks

This generator is built on the wisdom in following code:

- [phoenixframework/phoenix](https://github.com/phoenixframework/phoenix) for the Mix tasks.
- [sasa1977/mix_phx_alt](https://github.com/sasa1977/mix_phx_alt) for the project structure and [boundary](https://github.com/sasa1977/boundary) configuration.

## License

Apache License 2.0

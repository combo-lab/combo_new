# combo_new

An opinionated project generator for Combo.

## Usage

Install the archive of `combo_new`:

```
$ mix archive.install hex combo_new
```

Create a new Combo project:

```
# create a project from saas template
$ mix combo_new.saas demo
```

See `mix help` for more details.

## Features

- asset pipeline powered by Vite and Node.js ecosystem
- reduced number of processes running in dev environment, which is derived from [axelson's repo](https://github.com/axelson/hello_phoenix/pull/1)
- liveness probe, which is common in container environments.
- ...

## Why?

The project generator includes some templates tailored to my own needs. Since these templates are specially tailored, the project generator doesn't need that many options to meet different people's requirements.

Additionally, all the templates are directly executable projects, which makes development and debugging very simple.

## License

Apache License 2.0

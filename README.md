# combo_new

[![CI](https://github.com/combo-lab/combo_new/actions/workflows/ci.yml/badge.svg)](https://github.com/combo-lab/combo_new/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/combo_new.svg)](https://hex.pm/packages/combo_new)

The project generator for Combo.

## Installation

Install the archive of `combo_new`:

```
$ mix archive.install hex combo_new
```

## Usage

`combo_new` provides two main Mix tasks:

- `combo_new`. Run `mix help combo_new` for more information.
- `combo_new.update`. Run `mix help combo_new.update` for more information.

## Design philosophy

> These principles only apply to the templates in `combo_new`, not to your own templates.

- These templates only demonstrate features for building web interfaces. Other backend features, like data storage, authentication, authorization, telemetry, email sending, etc, are not demonstrated.
- These templates are designed to demonstrate the essential structure of a working project, not to encompass all possible requirements.
- These templates are standalone runnable projects. Although it limits the range of requirements that a single template can support, it makes development and debugging much simpler.

In this way, `combo_new` can focus on providing minimal, functional base templates, avoiding the maintenance overhead of accommodating diverse requirements.

Meanwhile, `combo_new` supports generating projects using remote Git repos, which allows users to tailor their own templates for their own needs, enabling the community to flourish without being too restrictive.

## Creating your own templates

If you need a template to provide additional features like user authentication, email sending, etc, you can copy the template from `combo_new` that best matches your needs, then modify it accordingly.

For instance, I've created my own template:

- [zekedou/combo-fullback-lite](https://github.com/zekedou/combo-fullstack-lite)

If you'd like to create one as well, please read [the guide of creating templates](./CREATING_TEMPLATES.md) for more information.

## License

[MIT](./LICENSE)

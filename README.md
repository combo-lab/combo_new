# combo_new

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

- Templates are designed to demonstrate the essential structure of a working project, not to encompass all possible requirements.
- Templates are standalone runnable projects. Although it limits the range of requirements that a single template can support, it makes development and debugging much simpler.
- Templates that include database functionality will always integrate with PostgreSQL - the world's most advanced open source RDBMS.

In this way, `combo_new` can focus on providing minimal, functional base templates, avoiding the maintenance overhead of accommodating diverse requirements. Meanwhile, community members can tailor their own templates to their specific needs, enabling the community to flourish without being too restrictive.

## Creating your own templates

If you need a template to provide additional features like user authentication, email sending, etc, you can copy the template from `combo_new` that best matches your needs, then modify it accordingly. Read [the guide of creating templates](./CREATING_TEMPLATES.md) for more information.

## License

MIT

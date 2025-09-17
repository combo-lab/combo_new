# MyApp

A Combo project using:

- Vite, TailwindCSS
- PostgreSQL

## Requirements

- Elixir
- Node.js

## Quick start

### Setup environments

```
$ mix setup
```

### Run dev server

```
$ iex -S mix combo.serve
```

Now you can visit [`localhost:4000`](http://localhost:4000) from web browser.

### Build release

```
$ mix deps.get --only prod
$ mix assets.deploy
$ MIX_ENV=prod mix release
```

## Deployment

Ready to run in production? Please [check out deployment guides](https://hexdocs.pm/combo/deployment.html).

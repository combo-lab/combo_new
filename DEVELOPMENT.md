This document describes how to develop this project.

## Build from source

```console
$ mix deps.get
$ mix compile
```

## Test locally

Remove any previously installed `combo_new` archives so that Mix will pick up the local source code:

```
$ mix archive.uninstall combo_new
```

Or, by simply deleting the file which is usually in `~/.mix/archives/`.

Then run:

```
$ MIX_ENV=prod mix do archive.build, archive.install
```

## Publish

```
$ mix publish
```

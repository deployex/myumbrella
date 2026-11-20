# Myumbrella

> Elixir umbrella applications can be smoothly hot-upgraded with [DeployEx][dye].

## Running Locally

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Genreating a hot-upgrade release

1. Build the initial release (e.g., `0.1.0`):
```bash
# Release the version 0.1.0
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
```

2. Update the version (e.g., from `0.1.0` to `0.1.1`) in `version.txt`
3. Build the new release with forced compilation:
```bash
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix compile --force
MIX_ENV=prod mix release
```

## Static Assets and Hot Upgrades

`assets.deploy` does not run `phx.digest`, and `cache_static_manifest` is left unset in `config/prod.exs`.
A hot upgrade overwrites `priv/static` in place on the running node, so a content-hashed filename would 404 for any browser tab that loaded the page before the upgrade.
Serving stable, undigested filenames keeps already-open sessions working across an upgrade.
This also means `Plug.Static`'s `gzip` option stays `false` in `app_web_web/endpoint.ex`, since there is no digest step producing pre-gzipped copies to serve.

## Continuous Integration

Every pull request is checked by [relup-guard-elixir][rge], which builds the release at the PR's base and head commits and runs a real relup install between them.
This catches hot-upgrade regressions before they merge.

## Observer Web Notes

If using Observer Web, install it in only one app (recommended: the LiveView web app).

[dye]: https://github.com/deployex/deployex
[rge]: https://github.com/deployex/relup-guard-elixir


# Haushalt App Store for umbrelOS

A community app store with one app, Einkaufsliste. umbrelOS installs apps from a public Git repository
and pulls their images from a registry, so two things have to be published before it can be installed:
the image and this folder.

## First release

1. **Push the image.** Sign in to your registry (`docker login ghcr.io`), then from the project root:

   ```bash
   umbrel-store/release.sh ghcr.io/hochschule-jz/einkaufsliste
   ```

   It builds for the Raspberry Pi (arm64), pushes, and writes the pinned image and the version into
   `haushalt-einkaufsliste/`. Make the image public in the registry; umbrelOS pulls without signing in.

2. **Publish this folder** as the root of the public repository
   `github.com/hochschule-jz/umbrel-haushalt-store`, which the manifest's links and icon point to.

3. **Add the store in umbrelOS:** App Store, the menu at the top right, Community App Stores, paste the
   repository URL. Then install Einkaufsliste from the „Haushalt“ store.

4. Open `http://umbrel.local:8642` (or your Tailscale name with that port) and create the first account.

## Updates

Raise `version` in `server/package.json` and `web/package.json`, run `release.sh` again, write what is
new into `releaseNotes` in `umbrel-app.yml`, and push this folder. umbrelOS then offers the update.

## Notes

- Data (database and photos) lives in the app's data folder on the Umbrel and survives updates.
- Umbrel's own login is not put in front of the app (`PROXY_AUTH_ADD: "false"`): the app has its own
  sign-in, and the Siri shortcut has to reach it.
- `port: 8642` must not be used by another app on the Umbrel; change it in `umbrel-app.yml` if it is.
- Never change the app `id` after the first install; the data folder is named after it.

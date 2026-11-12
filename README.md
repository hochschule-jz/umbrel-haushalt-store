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

## Using it without a connection (https)

Over `http://umbrel.local:8642` the app needs the server for every start. To open it in the shop without
a connection, it has to be installed from an https address; with Tailscale on the Umbrel that is Tailscale Serve:

1. In the Tailscale admin console, on the DNS page, turn on MagicDNS and „HTTPS Certificates“. This puts the
   Umbrel's machine name and the tailnet name into a public certificate log; access stays limited to your devices.
2. On the Umbrel over SSH, find the Tailscale container and turn on Serve for the app:

   ```bash
   sudo docker ps --format '{{.Names}}' | grep -i tailscale
   ```

   ```bash
   sudo docker exec tailscale_web_1 tailscale serve --bg --https=8443 http://localhost:8642
   ```

   ```bash
   sudo docker exec tailscale_web_1 tailscale serve status
   ```

   The last command shows the address, like `https://umbrel.tail1234.ts.net:8443`.
3. On each iPhone, with Tailscale on: open that address in Safari, sign in, add it to the Home Screen and delete
   the old icon. Replace the address in the Siri shortcut (Einstellungen shows the new one).
4. Check: open the app from the new icon, switch to flight mode, close the app and open it again. The lists
   appear with the „Offline“ row; changes are sent once the Umbrel is in reach again.

The https address only answers while Tailscale is on, at home too. With Tailscale off the app works from
its copy on the phone and sends the changes later. Updates arrive by themselves: the app fetches a new
version when it is opened and reloads once.

To undo: `sudo docker exec tailscale_web_1 tailscale serve --https=8443 off`. If the address stops answering
after an update of Umbrel's Tailscale app, run the `serve` command again.

## Notes

- Data (database and photos) lives in the app's data folder on the Umbrel and survives updates.
- Umbrel's own login is not put in front of the app (`PROXY_AUTH_ADD: "false"`): the app has its own
  sign-in, and the Siri shortcut has to reach it.
- `port: 8642` must not be used by another app on the Umbrel; change it in `umbrel-app.yml` if it is.
- Never change the app `id` after the first install; the data folder is named after it.

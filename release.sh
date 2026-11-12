#!/bin/sh
# Builds the image for the Raspberry Pi (arm64), pushes it to a registry, and writes the version
# and the pushed image, pinned by digest, into the umbrel package.
#
#   umbrel-store/release.sh ghcr.io/<you>/einkaufsliste
#
# Needs `docker login` for that registry first. The version comes from server/package.json.
# For an Umbrel on Intel/AMD set PLATFORM=linux/amd64. Both at once needs Docker's containerd image store.
set -eu

IMAGE=${1:?Usage: umbrel-store/release.sh <registry>/<name>, e.g. ghcr.io/you/einkaufsliste}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
APP="$ROOT/umbrel-store/haushalt-einkaufsliste"
VERSION=$(node -p "require('$ROOT/server/package.json').version")

docker build --platform "${PLATFORM:-linux/arm64}" --tag "$IMAGE:$VERSION" "$ROOT"
docker push "$IMAGE:$VERSION"
DIGEST=$(docker buildx imagetools inspect "$IMAGE:$VERSION" --format '{{.Manifest.Digest}}')

sed -i.bak "s|^    image: .*|    image: $IMAGE:$VERSION@$DIGEST|" "$APP/docker-compose.yml"
sed -i.bak "s|^version: .*|version: \"$VERSION\"|" "$APP/umbrel-app.yml"
rm -f "$APP/docker-compose.yml.bak" "$APP/umbrel-app.yml.bak"

echo "Pushed $IMAGE:$VERSION@$DIGEST"
echo "Now commit and push the umbrel-store folder; umbrelOS offers the update once the version changed."

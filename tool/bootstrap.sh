#!/usr/bin/env bash
# Regenerates missing Flutter platform files without overwriting lib/.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v flutter &>/dev/null; then
  echo "Flutter SDK not found. Install: https://docs.flutter.dev/get-started/install"
  exit 1
fi

flutter create \
  --org kz.newlevelhub \
  --project-name newlevelhub_mobile \
  --platforms android,ios \
  .

flutter pub get
flutter analyze

echo "Bootstrap complete. Run: flutter run"

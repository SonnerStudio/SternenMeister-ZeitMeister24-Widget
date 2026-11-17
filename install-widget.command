#!/usr/bin/env bash
set -euo pipefail

REPO="SonnerStudio/SternenMeister-ZeitMeister24-Widget"
ZIP_NAME="Zeitmeister24-Widget-macOS.zip"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "=================================================="
echo "  SternenMeister® Zeitmeister 24 — macOS Installer"
echo "=================================================="

if [ -f "$SCRIPT_DIR/$ZIP_NAME" ]; then
  echo "→ Lokales Paket gefunden: $ZIP_NAME"
  cp "$SCRIPT_DIR/$ZIP_NAME" "$TMP_DIR/$ZIP_NAME"
else
  echo "→ Lade neuestes Release von GitHub ($REPO)..."
  curl -fL "https://github.com/$REPO/releases/latest/download/$ZIP_NAME" -o "$TMP_DIR/$ZIP_NAME"
fi

echo "→ Entpacke ZeitmeisterApp.app..."
ditto -x -k "$TMP_DIR/$ZIP_NAME" "$TMP_DIR/extracted"

echo "→ Installiere nach /Applications/ZeitmeisterApp.app..."
killall ZeitmeisterApp 2>/dev/null || true
rm -rf /Applications/ZeitmeisterApp.app
cp -R "$TMP_DIR/extracted/ZeitmeisterApp.app" /Applications/ZeitmeisterApp.app
xattr -dr com.apple.quarantine /Applications/ZeitmeisterApp.app 2>/dev/null || true

echo "→ Registriere macOS Widget..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R -trusted /Applications/ZeitmeisterApp.app
pluginkit -a /Applications/ZeitmeisterApp.app/Contents/PlugIns/ZeitmeisterWidget.appex 2>/dev/null || true

echo "→ Starte SternenMeister Zeitmeister 24..."
open /Applications/ZeitmeisterApp.app

echo "✓ Installation abgeschlossen."

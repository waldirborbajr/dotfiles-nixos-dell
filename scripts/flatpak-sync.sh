#!/usr/bin/env bash
set -euo pipefail

REMOTE_NAME="flathub"
REMOTE_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

# Desired apps (kept in sync with modules/flatpak/packages.nix)
DESIRED_APPS=(
  "org.mozilla.firefox"
  "com.brave.Browser"
  "com.visualstudio.code"
  "com.discordapp.Discord"
  "me.proton.Mail"
  "md.obsidian.Obsidian"
  "com.anydesk.Anydesk"
  "org.gimp.GIMP"
  "org.inkscape.Inkscape"
  "org.audacityteam.Audacity"
  "fr.handbrake.ghb"
  "io.mpv.Mpv"
  "org.imagemagick.ImageMagick"
  "com.transmissionbt.Transmission"
  "be.alexandervanhee.gradia"
  "org.flameshot.Flameshot"
)

if ! command -v flatpak >/dev/null 2>&1; then
  echo "ERROR: flatpak not found in PATH."
  exit 1
fi

echo "Ensuring Flatpak remote: ${REMOTE_NAME}"
flatpak remote-add --if-not-exists "${REMOTE_NAME}" "${REMOTE_URL}" >/dev/null 2>&1 || true

echo "Reading installed apps..."
INSTALLED="$(flatpak list --app --columns=application 2>/dev/null || true)"

echo "Installing missing apps (and keeping existing ones)..."
for app in "${DESIRED_APPS[@]}"; do
  if echo "${INSTALLED}" | grep -q -F "${app}"; then
    echo "  OK: ${app}"
  else
    echo "  Installing: ${app}"
    flatpak install -y --noninteractive "${REMOTE_NAME}" "${app}" || true
  fi
done

echo "Updating Flatpaks..."
flatpak update -y --noninteractive || true

echo "Cleaning unused runtimes..."
flatpak uninstall --unused -y || true

echo "Done."

#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="com.github.amrutlabs-linux.ramspeedometer"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Error: kpackagetool6 not found. Install Plasma 6 development tools first." >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --show "$PACKAGE_ID" >/dev/null 2>&1; then
    echo "Updating existing installation of $PACKAGE_ID ..."
    kpackagetool6 --type Plasma/Applet -u "$SCRIPT_DIR"
else
    echo "Installing $PACKAGE_ID ..."
    kpackagetool6 --type Plasma/Applet -i "$SCRIPT_DIR"
fi

echo
echo "Done. To apply the changes, restart Plasma Shell with either:"
echo "  systemctl --user restart plasma-plasmashell.service"
echo "or:"
echo "  plasmashell --replace &"
echo
echo "Then add the widget via: right-click desktop/panel -> Add Widgets -> RAM Speedometer."

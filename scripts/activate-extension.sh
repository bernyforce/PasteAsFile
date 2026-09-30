#!/bin/bash
# Enregistre et active l'extension Finder du projet, sans clic.
#   scripts/activate-extension.sh [chemin du .app installé]   (défaut : /Applications/PasteAsFile.app)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
APP="${1:-/Applications/PasteAsFile.app}"
APPX="$APP/Contents/PlugIns/PasteAsFileFinder.appex"
if [ ! -d "$APPX" ]; then
    echo "absent : $APPX" >&2
    echo "Installez d'abord l'application (scripts/build-signed.sh)." >&2
    exit 1
fi
BID=$(/usr/bin/plutil -p "$APPX/Contents/Info.plist" | grep CFBundleIdentifier | cut -d'"' -f4)
echo "appex       : $APPX"
echo "identifiant : $BID"

if /usr/bin/codesign -dv "$APPX" 2>&1 | grep -q "TeamIdentifier=not set"; then
    echo "AVERTISSEMENT : signature sans identifiant d'équipe (ad hoc ou auto-signée)."
    echo "macOS 26 refuse alors l'enregistrement par pkd (cf. docs/VERDICT.md, ÉTAPE 4)."
fi

# -r/‑a/‑e ciblent uniquement l'appex du projet : les extensions tierces ne sont pas touchées.
/usr/bin/pluginkit -r "$APPX"
/usr/bin/pluginkit -a "$APPX"
/usr/bin/pluginkit -e use -i "$BID"
sleep 2

if /usr/bin/pluginkit -m -A -D -i "$BID" | grep -qi pasteasfile; then
    echo "ACTIVÉ :"
    /usr/bin/pluginkit -m -A -D -i "$BID" -v
    /usr/bin/killall Finder
    echo "Finder relancé. Test : clic droit dans une fenêtre du dossier personnel > « Coller à partir du presse-papier »."
    exit 0
fi

echo "REFUSÉ : pkd n'a pas enregistré l'extension."
echo "Cause mesurée : signature non délivrée par Apple (docs/VERDICT.md, ÉTAPE 4)."
echo "Correctif : CODE_SIGN_IDENTITY=\"Apple Development: …\" scripts/build-signed.sh puis relancer ce script."
exit 2

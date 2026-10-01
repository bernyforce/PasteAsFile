#!/bin/bash
# Build Release signé avec une identité Apple, puis installation dans /Applications.
#   CODE_SIGN_IDENTITY="Apple Development: Prénom Nom (TEAMID)" scripts/build-signed.sh
#   (DEVELOPMENT_TEAM=XXXXXXXXXX en complément si l'identité n'expose pas l'équipe)
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1
: "${CODE_SIGN_IDENTITY:?Définissez CODE_SIGN_IDENTITY (identité Apple du trousseau : security find-identity -v -p codesigning)}"
cleanup_foreign_appex() {
    find /tmp "$HOME/Library/Developer/Xcode/DerivedData" -name "PasteAsFileFinder.appex" 2>/dev/null | while read -r appex; do
        if [[ "$appex" != /Applications/* ]]; then
            pluginkit -r "$appex" 2>/dev/null || true
            rm -rf "$appex" 2>/dev/null || true
        fi
    done
}
cleanup_foreign_appex
DERIVED="${PASTE_DERIVED:-/tmp/pasteasfile-build/xcode-signed}"
rm -rf "$DERIVED"

env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
    -project PasteAsFile.xcodeproj -scheme PasteAsFile -configuration Release \
    -derivedDataPath "$DERIVED" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    ${DEVELOPMENT_TEAM:+DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"} \
    build

APP="$DERIVED/Build/Products/Release/PasteAsFile.app"
codesign --verify --deep --strict --verbose=2 "$APP"
rm -rf /Applications/PasteAsFile.app
/usr/bin/ditto "$APP" /Applications/PasteAsFile.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/PasteAsFile.app
codesign -dv /Applications/PasteAsFile.app/Contents/PlugIns/PasteAsFileFinder.appex 2>&1 | grep -E "Authority|TeamIdentifier"
echo "installé : /Applications/PasteAsFile.app"
# Une seule copie enregistrée par pkd : le produit de scratch est retiré après installation
rm -rf "$APP"
cleanup_foreign_appex
echo "scratch retiré : $APP"
echo "étape suivante : scripts/activate-extension.sh"

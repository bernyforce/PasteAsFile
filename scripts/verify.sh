#!/bin/bash
# Socle déterministe V1-V5 (mission PasteAsFile).
# Les artefacts de build sont produits dans un volume local APFS ($SCRATCH, défaut
# /tmp/pasteasfile-build) et non dans le dossier Google Drive : Drive pose des
# attributs com.apple.FinderInfo / com.apple.fileprovider.* qui font échouer
# codesign --verify --deep --strict ("resource fork, Finder information, or similar
# detritus not allowed"). Voir docs/ARBITRAGES.md. Les sources restent dans le dépôt.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
SCRATCH="${PASTE_SCRATCH:-/tmp/pasteasfile-build}"
DEV="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
mkdir -p "$SCRATCH" docs/logs
failed=0
run() {
    local name="$1"; shift
    printf '\n=== %s ===\n' "$name"
    printf '[%s] $ %s\n' "$(date -Iseconds)" "$*" >> docs/logs/commands.log
    "$@" >"docs/logs/${name}.log" 2>&1
    local rc=$?
    printf '[%s] rc=%s log=docs/logs/%s.log\n' "$(date -Iseconds)" "$rc" "$name" >> docs/logs/commands.log
    /bin/cat "docs/logs/${name}.log"
    printf '%s exit=%s\n' "$name" "$rc"
    if [ "$rc" -ne 0 ]; then failed=1; fi
    return 0
}
run V1 env DEVELOPER_DIR="$DEV" swift build -Xswiftc -warnings-as-errors --scratch-path "$SCRATCH/spm"
run V2 env DEVELOPER_DIR="$DEV" swift test -Xswiftc -warnings-as-errors --scratch-path "$SCRATCH/spm"
run V3-app env DEVELOPER_DIR="$DEV" xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFile -configuration Release -derivedDataPath "$SCRATCH/xcode" build
run V3-finder env DEVELOPER_DIR="$DEV" xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFileFinder -configuration Release -derivedDataPath "$SCRATCH/xcode" build
run V4-plist plutil -lint PasteAsFile/Info.plist PasteAsFileFinder/Info.plist PasteAsFileFinder/PasteAsFileFinder.entitlements PasteAsFile.xcodeproj/project.pbxproj
run V4-point /bin/bash -c "test \"\$(/usr/libexec/PlistBuddy -c 'Print NSExtension:NSExtensionPointIdentifier' PasteAsFileFinder/Info.plist)\" = com.apple.FinderSync"
run V4-sandbox /bin/bash -c "test \"\$(/usr/libexec/PlistBuddy -c 'Print com.apple.security.app-sandbox' PasteAsFileFinder/PasteAsFileFinder.entitlements)\" = false"
APP="$SCRATCH/xcode/Build/Products/Release/PasteAsFile.app"
if [ -d "$APP" ]; then
    run V5 codesign --verify --deep --strict --verbose=2 "$APP"
else
    printf 'V5 NOT RUN: application absente (%s)\n' "$APP" | tee docs/logs/V5.log
    failed=1
fi
exit "$failed"

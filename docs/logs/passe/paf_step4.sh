#!/bin/bash
set -u
REPO="/Users/bf/Library/CloudStorage/GoogleDrive-bernynoussi@gmail.com/Mon Drive/Formation/Collège BDEB/ETE_2026/420-A60-BB ALGORITHMES D'APPRENTISSAGE PROFOND/Examen Final/PasteAsFile"
cd "$REPO" || exit 1
DD="$HOME/Library/Developer/Xcode/DerivedData/PasteAsFile-dgpbpeznkgqoaobgpyrnpeucjuwy/Build/Products/Release"
echo "=== V5 littéral sur le build DerivedData ==="
scripts/jrn.sh v5_codesign_deriveddata codesign --verify --deep --strict --verbose=2 "$DD/PasteAsFile.app"
scripts/jrn.sh v5_codesign_deriveddata_appex codesign --verify --deep --strict --verbose=2 "$DD/PasteAsFileFinder.appex"
echo "=== racine du build litteral ==="
ls -d "$DD"/* | head -12

LOG=docs/logs/v6_pluginkit.log
: > "$LOG"
run() { printf '\n=== $ %s\n' "$*" >> "$LOG"; "$@" >> "$LOG" 2>&1; printf 'rc=%s\n' "$?" >> "$LOG"; }
APP=/Applications/PasteAsFile.app
APPX="$APP/Contents/PlugIns/PasteAsFileFinder.appex"
printf '### ÉTAPE 4 — enregistrement et activation (reprise, %s)\n' "$(date -Iseconds)" >> "$LOG"
rm -rf "$APP"
/usr/bin/ditto "$DD/PasteAsFile.app" "$APP"
printf 'appex installé : %s\n' "$APPX" >> "$LOG"
run /usr/bin/pluginkit -r "$APPX"
run /usr/bin/pluginkit -a "$APPX"
BID=$(/usr/bin/plutil -p "$APPX/Contents/Info.plist" | grep CFBundleIdentifier | cut -d'"' -f4)
printf 'identifiant = %s\n' "$BID" >> "$LOG"
run /usr/bin/pluginkit -e use -i "$BID"
printf '\n=== $ pluginkit -m -A -D | grep -i pasteasfile\n' >> "$LOG"
/usr/bin/pluginkit -m -A -D 2>&1 | grep -i pasteasfile >> "$LOG"
printf 'rc=%s  (rc=1 : aucune ligne retournee par pkd)\n' "$?" >> "$LOG"
printf '\n=== $ pluginkit -m -A -D -i %s\n' "$BID" >> "$LOG"
/usr/bin/pluginkit -m -A -D -i "$BID" >> "$LOG" 2>&1
run /usr/bin/killall Finder
printf '\n=== pkd, cause du refus (extraits bruts, cf. 6a-6e) ===\n' >> "$LOG"
tail -n 8 docs/logs/6d_pkd_journal.txt >> "$LOG"
cat "$LOG"

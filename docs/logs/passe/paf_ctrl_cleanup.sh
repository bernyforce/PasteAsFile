#!/bin/bash
# Controle final + nettoyage des sondes
set -u
G="/Applications/Google Drive.app/Contents/Applications/FinderHelper.app/Contents/PlugIns/FinderSyncExtension.appex"
P=/Applications/ProbeCtrl.app/Contents/PlugIns/FinderSyncExtension.appex
rm -rf /Applications/ProbeCtrl.app
mkdir -p /Applications/ProbeCtrl.app/Contents/PlugIns
/usr/bin/ditto "$G" "$P"
echo "--- codesign dv (copie intacte via ditto) ---"
codesign -dv "$P" 2>&1 | grep -E "Authority|Signature=" | head -3
/usr/bin/pluginkit -a "$P"
sleep 4
echo "--- probe enregistre ? (grep chemin ProbeCtrl) ---"
/usr/bin/pluginkit -m -A -D -v 2>&1 | grep -c "ProbeCtrl"
echo "--- findersync total ---"
/usr/bin/pluginkit -m -A -D -v -p com.apple.FinderSync 2>&1 | tail -1
rm -rf /Applications/ProbeCtrl.app
echo "--- nettoyage identite locale ---"
if [ -f /tmp/cert-probe/c.pem ]; then security remove-trusted-cert /tmp/cert-probe/c.pem 2>&1 | tail -1; fi
security delete-certificate -c "PasteAsFile Local Dev" "$HOME/Library/Keychains/login.keychain-db" 2>&1 | tail -1
security find-identity -v -p codesigning | tail -1
rm -rf /tmp/adhoc-probe /tmp/cert-probe
echo "--- reinstalle l'artefact verifie (ad-hoc, tel que construit) ---"
rm -rf /Applications/PasteAsFile.app
/usr/bin/ditto /tmp/pasteasfile-build/xcode/Build/Products/Release/PasteAsFile.app /Applications/PasteAsFile.app
codesign --verify --deep --strict /Applications/PasteAsFile.app && echo "install ad-hoc verifiee"
/usr/bin/pluginkit -a /Applications/PasteAsFile.app/Contents/PlugIns/PasteAsFileFinder.appex
/usr/bin/pluginkit -e use -i org.pasteasfile.PasteAsFileFinder
echo "--- etat final pkd ---"
/usr/bin/pluginkit -m -A -D -i org.pasteasfile.PasteAsFileFinder -v
echo "rc=$?"

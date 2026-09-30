#!/bin/bash
set -u
REPO="/Users/bf/Library/CloudStorage/GoogleDrive-bernynoussi@gmail.com/Mon Drive/Formation/Collège BDEB/ETE_2026/420-A60-BB ALGORITHMES D'APPRENTISSAGE PROFOND/Examen Final/PasteAsFile"
cd "$REPO" || exit 1
CO=$HOME/.hermes/cache/terminal-output
cp "$CO/probe_adhoc.txt"   docs/logs/6a_probe_appex_adhoc.txt
cp "$CO/probe_cert5.txt"   docs/logs/6b_probe_identite_locale.txt
cp "$CO/probe_runtime.txt" docs/logs/6c_probe_runtime.txt
cp "$CO/probe_pkd.txt"     docs/logs/6d_pkd_journal.txt
cp "$CO/probe_final.txt"   docs/logs/6e_probe_final.txt
ls -la docs/logs/
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/jrn.sh v3_build_app_inline xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFile -configuration Release build
scripts/jrn.sh v3_build_finder_inline xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFileFinder -configuration Release build

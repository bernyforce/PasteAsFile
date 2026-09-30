#!/bin/bash
# Étape manuelle unique : depuis Terminal, exécuter sudo scripts/unblock_xcode.sh.
# L'utilisateur accepte ainsi lui-même la licence Xcode et l'installation initiale.
set -euo pipefail
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcode-select -p
xcodebuild -version
xcrun --find xctest

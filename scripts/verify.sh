#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/logs
export PASTE_BUILD_DIR="$PWD/build"
failed=0
run() {
    local name="$1"; shift
    printf '\n=== %s ===\n' "$name"
    "$@" >"build/logs/${name}.log" 2>&1
    local rc=$?
    /bin/cat "build/logs/${name}.log"
    printf '%s exit=%s\n' "$name" "$rc"
    if [ "$rc" -ne 0 ]; then failed=1; fi
}
run V1 swift build -Xswiftc -warnings-as-errors --build-path build/spm
run V2 swift test -Xswiftc -warnings-as-errors --build-path build/spm
run V3-app env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFile -configuration Release -derivedDataPath "$PWD/build/xcode" build
run V3-finder env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFileFinder -configuration Release -derivedDataPath "$PWD/build/xcode" build
run V4-plist plutil -lint PasteAsFile/Info.plist PasteAsFileFinder/Info.plist PasteAsFileFinder/PasteAsFileFinder.entitlements PasteAsFile.xcodeproj/project.pbxproj
run V4-point /bin/bash -c "test \"\$(/usr/libexec/PlistBuddy -c 'Print NSExtension:NSExtensionPointIdentifier' PasteAsFileFinder/Info.plist)\" = com.apple.FinderSync"
run V4-sandbox /bin/bash -c "test \"\$(/usr/libexec/PlistBuddy -c 'Print com.apple.security.app-sandbox' PasteAsFileFinder/PasteAsFileFinder.entitlements)\" = false"
if [ -d build/xcode/Build/Products/Release/PasteAsFile.app ]; then
    run V5 codesign --verify --deep --strict "$PWD/build/xcode/Build/Products/Release/PasteAsFile.app"
else
    printf 'V5 NOT RUN: application absente\n' | tee build/logs/V5.log
    failed=1
fi
exit "$failed"

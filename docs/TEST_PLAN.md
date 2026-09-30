# Matrice de vérification

| Critère | Test | Commande |
|---|---|---|
| V1 | compilation sans avertissement | `swift build -Xswiftc -warnings-as-errors --build-path build/spm` |
| V2 | T1–T14 | `swift test -Xswiftc -warnings-as-errors --build-path build/spm` |
| V3 | application et extension Release | `xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFile -configuration Release -derivedDataPath build/xcode build` ; même commande avec `-scheme PasteAsFileFinder` |
| V4 | plist et sandbox | `plutil -lint PasteAsFileFinder/Info.plist`; inspection automatisée avec `PlistBuddy` |
| V5 | signature de l'app | `codesign --verify --deep --strict build/xcode/Build/Products/Release/PasteAsFile.app` |

T1–T5 : TIFF, PNG, JPEG, ICNS, PDF → extensions exactes. T6 : RTF avant texte. T7 : HTML. T8 : texte brut. T9 : UTI inconnu, rien écrit. T10 : horodatage exact. T11 : collisions successives. T12 : SHA256 des octets entrée/sortie. T13 : fichiers copiés avec unicité. T14 : texte riche au format RTF. Tests dans `Tests/PasteAsFileCoreTests`; script orchestrateur `scripts/verify.sh`.

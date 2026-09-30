# Verdict indépendant et preuves

Conformité intégrale : NON DÉMONTRÉE. Les blocages ne sont pas des succès.

| Critère | Statut | Preuve / motif |
|---|---|---|
| V1 | PASS | Swift SPM compilé sans avertissement |
| V2 | BLOCKED | XCTest absent des Command Line Tools |
| V3 application | BLOCKED | Licence Xcode non acceptée |
| V3 extension | BLOCKED | Licence Xcode non acceptée |
| V4 | PASS | Plists, identifiant FinderSync et sandbox=false |
| V5 | BLOCKED | Aucun .app produit pour codesign |
| T1 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T2 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T3 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T4 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T5 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T6 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T7 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T8 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T9 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T10 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T11 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T12 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T13 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |
| T14 | BLOCKED | Test XCTest écrit mais non exécuté ; smoke séparé non substitutif |

## Sorties brutes de scripts/verify.sh

### V1 — build/logs/V1.log
```text
[0/1] Planning build
Building for debugging...
[0/1] Write swift-version--1AB21518FC5DEDBE.txt
[2/3] Emitting module PasteAsFileCore
[3/3] Compiling PasteAsFileCore PasteLogic.swift
Build complete! (0.37s)
```

### V2 — build/logs/V2.log
```text
[0/1] Planning build
Building for debugging...
[0/3] Write swift-version--1AB21518FC5DEDBE.txt
error: emit-module command failed with exit code 1 (use -v to see invocation)
[2/5] Emitting module PasteAsFileCoreTests
/Users/bf/Library/CloudStorage/GoogleDrive-bernynoussi@gmail.com/Mon Drive/Formation/Collège BDEB/ETE_2026/420-A60-BB ALGORITHMES D'APPRENTISSAGE PROFOND/Examen Final/PasteAsFile/Tests/PasteAsFileCoreTests/PasteLogicTests.swift:1:8: error: no such module 'XCTest'
 1 | import XCTest
   |        `- error: no such module 'XCTest'
 2 | import AppKit
 3 | import CryptoKit
[3/5] Compiling PasteAsFileCoreTests PasteLogicTests.swift
/Users/bf/Library/CloudStorage/GoogleDrive-bernynoussi@gmail.com/Mon Drive/Formation/Collège BDEB/ETE_2026/420-A60-BB ALGORITHMES D'APPRENTISSAGE PROFOND/Examen Final/PasteAsFile/Tests/PasteAsFileCoreTests/PasteLogicTests.swift:1:8: error: no such module 'XCTest'
 1 | import XCTest
   |        `- error: no such module 'XCTest'
 2 | import AppKit
 3 | import CryptoKit
error: fatalError
```

### V3-app — build/logs/V3-app.log
```text
You have not agreed to the Xcode license agreements. Please run 'sudo xcodebuild -license' from within a Terminal window to review and agree to the Xcode and Apple SDKs license.
```

### V3-finder — build/logs/V3-finder.log
```text
You have not agreed to the Xcode license agreements. Please run 'sudo xcodebuild -license' from within a Terminal window to review and agree to the Xcode and Apple SDKs license.
```

### V4-plist — build/logs/V4-plist.log
```text
PasteAsFile/Info.plist: OK
PasteAsFileFinder/Info.plist: OK
PasteAsFileFinder/PasteAsFileFinder.entitlements: OK
PasteAsFile.xcodeproj/project.pbxproj: OK
```

### V4-point — build/logs/V4-point.log
```text

```

### V4-sandbox — build/logs/V4-sandbox.log
```text

```

V5 : `NOT RUN: application absente` ; scripts/verify.sh a terminé avec exit code 1.

Contrôles supplémentaires réellement effectués : `swiftc -warnings-as-errors -typecheck` sur le cœur, Finder et app (exit 0) ; compilateur Swift autonome avec NSPasteboard de test (exit 0), sortie :

```text
SMOKE PASS: formats, priorité, nommage, collisions, SHA256, copies, NSPasteboard PNG/TIFF/RTF
```

Relecture externe indépendante : tests et binaires non prouvés ; schémas partagés ajoutés à `xcshareddata/xcschemes` après constat. Le commit et les schémas doivent être vérifiés à la clôture.

Blocage concret : l'accord à la licence Xcode doit être fait par le titulaire de la machine. Ne pas représenter le smoke comme T1–T14 exécutés.

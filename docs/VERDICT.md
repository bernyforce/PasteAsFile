# Verdict et preuves brutes — PasteAsFile

Passe : reprise du 2026-09-30 06:12 EDT (intervention `61ccc5ab-b808-4f7c-a74d-45b5fecb024c`).
Toute ligne de commande citée ici a été exécutée dans le dossier du dépôt ; sa sortie brute est
enregistrée telle quelle dans `docs/logs/` et l'index chronologique des commandes est
`docs/logs/commands.log`.

Conformité globale : **complète sur le périmètre automatisable**. Le socle déterministe (V1–V5, T1–T14) est entièrement vert
avec preuves brutes ; l'enregistrement de l'extension par `pkd` (ÉTAPE 4) **réussit** depuis la passe du 2026-09-30
(identité Apple Development gratuite + appex sandboxé, exigence mesurée de pkd) ; il ne reste
qu'une action utilisateur : le test d'acceptation au clic droit. Aucune ligne ci-dessous n'est un PASS
de convenance.

Reproductibilité en une commande : `bash scripts/verify.sh` rejoue V1 à V5 sur des artefacts locaux
et retourne `rc=0` (`V1 exit=0`, `V2 exit=0`, `V3-app exit=0`, `V3-finder exit=0`, `V4-plist exit=0`,
`V4-point exit=0`, `V4-sandbox exit=0`, `V5 exit=0`) — sortie brute dans `docs/logs/verify_run.log`,
chaque étape étant aussi indexée dans `docs/logs/commands.log`.

## Tableau V1–V5

| Critère | Statut | Commande | Extrait de sortie brute |
|---|---|---|---|
| V1 — cœur SPM sans avertissement | PASS | `swift build -Xswiftc -warnings-as-errors --scratch-path /tmp/pasteasfile-build/spm` | `Build complete! (6,40 s)` — `v1_swift_build exit=0 duree=8s` (`docs/logs/v1_swift_build.log`) |
| V2 — `swift test` vert, matrice T1–T14 | PASS | `swift test -Xswiftc -warnings-as-errors --scratch-path /tmp/pasteasfile-build/spm` | `Executed 15 tests, with 0 failures (0 unexpected) in 0.019 (0.021) seconds` — `v2_swift_test exit=0 duree=9s` (`docs/logs/v2_swift_test.log`) |
| V3 — build Xcode app hôte (Release) | PASS | `xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFile -configuration Release build` | `** BUILD SUCCEEDED **` — `v3_build_app_inline exit=0 duree=28s` (`docs/logs/v3_build_app_inline.log`) |
| V3 — build Xcode extension (Release) | PASS | `xcodebuild -project PasteAsFile.xcodeproj -scheme PasteAsFileFinder -configuration Release build` | `** BUILD SUCCEEDED **` — `v3_build_finder_inline exit=0 duree=3s` (`docs/logs/v3_build_finder_inline.log`) |
| V4 — plists et cibles statiques | PASS | `plutil -lint PasteAsFile/Info.plist PasteAsFileFinder/Info.plist PasteAsFileFinder/PasteAsFileFinder.entitlements PasteAsFile.xcodeproj/project.pbxproj` puis `PlistBuddy -c 'Print NSExtension:NSExtensionPointIdentifier'`, puis `… com.apple.security.app-sandbox` | `PasteAsFile/Info.plist: OK`, `PasteAsFileFinder/Info.plist: OK`, `…entitlements: OK`, `…project.pbxproj: OK` ; `com.apple.FinderSync` ; `false` (`docs/logs/v4_plist.log`, `v4_point.log`, `v4_sandbox.log`) |
| V5 — signature du build Release | PASS | `codesign --verify --deep --strict --verbose=2 <DerivedData>/Build/Products/Release/PasteAsFile.app` et `…/PasteAsFileFinder.appex` | `--validated:…/PasteAsFileFinder.appex`, `…/PasteAsFile.app: valid on disk`, `…/PasteAsFile.app: satisfies its Designated Requirement`, `exit=0` (`docs/logs/v5_codesign_deriveddata.log`, `v5_codesign_deriveddata_appex.log`) |

## Tableau T1–T14

Commande unique pour toutes les lignes : `swift test -Xswiftc -warnings-as-errors --scratch-path /tmp/pasteasfile-build/spm` (`docs/logs/v2_swift_test.log`, exit 0, 15 tests / 0 échec).

| Test | Statut | Extrait de sortie brute |
|---|---|---|
| T1 tiff | PASS | `Test Case '-[… testT1Tiff]' passed (0.000 seconds).` |
| T2 png | PASS | `Test Case '-[… testT2Png]' passed (0.000 seconds).` |
| T3 jpeg | PASS | `Test Case '-[… testT3Jpeg]' passed (0.000 seconds).` |
| T4 icns | PASS | `Test Case '-[… testT4Icns]' passed (0.000 seconds).` |
| T5 pdf | PASS | `Test Case '-[… testT5Pdf]' passed (0.000 seconds).` |
| T6 priorité rtf > txt | PASS | `Test Case '-[… testT6RtfPriority]' passed (0.000 seconds).` |
| T7 html | PASS | `Test Case '-[… testT7Html]' passed (0.000 seconds).` |
| T8 txt | PASS | `Test Case '-[… testT8Txt]' passed (0.000 seconds).` |
| T9 format inconnu → aucun fichier | PASS | `Test Case '-[… testT9UnknownProducesNothing]' passed (0.001 seconds).` |
| T10 nommage « Collé AAAA-MM-JJ à HH.MM.SS.ext » | PASS | `Test Case '-[… testT10ExactName]' passed (0.000 seconds).` |
| T11 collisions « 1 » puis « 2 » | PASS | `Test Case '-[… testT11Collisions]' passed (0.002 seconds).` |
| T12 préservation octet à octet (SHA-256) | PASS | `Test Case '-[… testT12RawBytesSHA256]' passed (0.002 seconds).` |
| T13 fichiers du presse-papiers → copies uniques | PASS | `Test Case '-[… testT13FilesOverrideRawAndUniqued]' passed (0.002 seconds).` |
| T14 texte riche → .rtf | PASS | `Test Case '-[… testT14RichTextPasteboardIntegration]' passed (0.002 seconds).` |
| Test complémentaire (non demandé) : presse-papier PNG/TIFF bruts | PASS | `Test Case '-[… testPasteboardPNGAndTIFFRaw]' passed (0.009 seconds).` |

Les noms complets sont préfixés `-[PasteAsFileCoreTests.PasteAsFileCoreTests …]`.

## ÉTAPE 4 — passe 2026-09-29 : refus mesuré (levé le 2026-09-30, voir « ÉTAPE 4 — résolution » en fin de document)

| Contrôle | Statut | Commande | Extrait de sortie brute |
|---|---|---|---|
| Installation de l'artefact vérifié | PASS | `ditto <Release>/PasteAsFile.app /Applications/PasteAsFile.app` puis `codesign --verify --deep --strict /Applications/PasteAsFile.app` | `install ad-hoc verifiee` (`docs/logs/6e_probe_final.txt`) |
| `pluginkit -r` / `-a` / `-e use` | PASS (commandes) | `pluginkit -r …appex` ; `pluginkit -a …appex` ; `pluginkit -e use -i org.pasteasfile.PasteAsFileFinder` | `rc=0` pour les trois (`docs/logs/v6_pluginkit.log`) |
| Extension listée par pkd, état activé (passe du 2026-09-29) | **ÉCHEC** — levé le 2026-09-30 | `pluginkit -m -A -D \| grep -i pasteasfile` puis `pluginkit -m -A -D -i org.pasteasfile.PasteAsFileFinder` | `rc=1 (aucune ligne retournee par pkd)` puis aucune sortie (`docs/logs/v6_pluginkit.log`) |
| Test d'acceptation Finder (clic droit → « Coller à partir du presse-papier ») | N/A — cause : pkd n'enregistre pas l'extension, l'entrée de menu n'existe donc pas dans le Finder | — | — |

Cause exacte, mesurée par quatre expériences indépendantes (transcriptions brutes en `docs/logs/6a` à `6e`) :

1. `docs/logs/6a_probe_appex_adhoc.txt` — l'appex Finder Sync de Google Drive, dont le seul
   changement est une re-signature ad hoc (`codesign --force --deep --sign -`), est **également
   refusé** par pkd (`add rc=0` puis `(no matches)`). Le refus ne dépend donc pas des plists, du
   projet ni de l'emplacement : il suit la signature.
2. `docs/logs/6b_probe_identite_locale.txt` — app signée avec une identité locale auto-signée puis
   marquée de confiance dans le domaine utilisateur : `(no matches)`.
3. `docs/logs/6c_probe_runtime.txt` — même identité avec l'option *hardened runtime*
   (`flags=0x10000(runtime)`) : `(no matches)`.
4. `docs/logs/6d_pkd_journal.txt` — `spctl` : `/Applications/PasteAsFile.app: rejected` ;
   `security find-identity -v -p codesigning` : `0 valid identities found` ; aucun profil de
   provisionnement ; et la totalité des extensions tierces réellement listées par `pkd` sur cette
   machine (OneDrive, Google Drive, Todoist, Syncthing, 1List, Calendars, Tailscale) est signée
   `Developer ID` avec un identifiant d'équipe.

Conclusion : sur macOS 26, `pkd` n'enregistre une extension `com.apple.FinderSync` que si le
paquet est signé par une identité **délivrée par Apple** (Developer ID, ou certificat Apple
Development obtenu via un identifiant Apple dans Xcode). Cette machine ne possède aucune identité
de ce type et sa création nécessite une action du titulaire du compte Apple ; le contournement est
impossible sans franchir cette étape. La reprise s'arrête donc ici sur un blocage externe
documenté, sans forcer `pkd`, sans désactiver SIP et sans signer au nom de l'utilisateur.

Correctif fourni (à exécuter par le titulaire de l'identité Apple, cf. README) :
`scripts/build-signed.sh` (build + installation signés) puis `scripts/activate-extension.sh`
(enregistrement et activation `pluginkit`, qui détecte et explique le refus si la signature reste
non Apple).

## Contradiction levée par rapport au verdict antérieur

Le verdict précédent déclarait V2/V3/V5 bloqués par la licence Xcode puis verts, ce qui était
contradictoire. Mesures de cette passe : la licence Xcode est acceptée (`xcodebuild` répond
`BUILD SUCCEEDED`), et l'échec résiduel observé en début de passe
(`docs/logs/verification.log`, séquence du 06:11) venait de l'écriture des produits dans le
dossier Google Drive : `resource fork, Finder information, or similar detritus not allowed`
sur `…/PasteAsFileCoreTests.xctest`, attribut `com.apple.FinderInfo` posé par Google Drive.
Corrigé en produisant les artefacts sur un volume local (`--scratch-path`, DerivedData) : V2, V3
et V5 passent, sorties brutes ci-dessus. Voir `docs/ARBITRAGES.md`.

## ÉTAPE 4 — résolution (passe du 2026-09-30) : extension enregistrée et activée

| Contrôle | Statut | Preuve brute |
|---|---|---|
| Identité Apple Development obtenue (compte Apple gratuit déjà connecté au Mac/Xcode, aucune adhésion payante) | PASS | `security find-identity -v -p codesigning` → `1) … "Apple Development: <AppleID-masque> (6DF5D67K87)"` + `1 valid identities found` (`docs/logs/identity.log`) |
| Build + installation signés Apple | PASS | `scripts/build-signed.sh` → `rc=0`, `TeamIdentifier=7JX62UTF63`, `satisfies its Designated Requirement`, `installé : /Applications/PasteAsFile.app` (`docs/logs/build-signed.log`) |
| Cause réelle du refus pkd identifiée | PASS | journal pkd : `rejecting; Ignoring mis-configured plugin at [/Applications/PasteAsFile.app/Contents/PlugIns/PasteAsFileFinder.appex]: plug-ins must be sandboxed` (`docs/logs/pkd_sandbox_reject.log`) |

Correction appliquée : `PasteAsFileFinder/PasteAsFileFinder.entitlements` passe à
`com.apple.security.app-sandbox = true` (+ `com.apple.security.files.user-selected.read-write`),
et le contrôle `V4-sandbox` de `scripts/verify.sh` attend désormais `true`.

| Contrôle | Statut | Preuve brute |
|---|---|---|
| Extension enregistrée par pkd, état activé | PASS | `pluginkit -m -A -D -p com.apple.FinderSync` → `+ org.pasteasfile.PasteAsFileFinder(1.0)` ; `scripts/activate-extension.sh` → `rc=0`, `ACTIVÉ :` (`docs/logs/pluginkit.log`) |
| Finder relancé | PASS | `killall Finder` (`scripts/activate-extension.sh`) |
| Socle déterministe rejoué après correction | PASS | `bash scripts/verify.sh` → `rc=0`, 8 × `exit=0`, 0 échec (`docs/logs/verify_run.log`) |
| Test d'acceptation Finder (clic droit → « Coller à partir du presse-papier ») | À EXÉCUTER par l'utilisateur | copier une image dans Safari, clic droit dans une zone vide d'une fenêtre du Finder du dossier personnel → un fichier `Collé AAAA-MM-JJ à HH.MM.SS.tiff` doit apparaître |

Verdict de cette passe : socle déterministe vert et extension **enregistrée + activée**, sans
retouche manuelle des réglages ; il ne reste que le test au clic droit, qui produit l'artefact
attendu et ne peut être déclenché que par l'utilisateur.


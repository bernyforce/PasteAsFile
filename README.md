# PasteAsFile — extension Finder « Coller à partir du presse-papier »

Extension Finder Sync (macOS 13+) ajoutant l'entrée « Coller à partir du presse-papier » au menu
contextuel du Finder, plus l'application hôte qui l'héberge.

## Comportement

- Presse-papier contenant des fichiers → ils sont copiés dans le dossier visé, sans écrasement
  (suffixes ` 1`, ` 2`, …).
- Sinon → un fichier est créé à partir des octets bruts du presse-papier, sans conversion
  (SHA-256 identique à la source), nommé `Collé AAAA-MM-JJ à HH.MM.SS.ext`.
- Formats prioritaires (UTI → extension) : `public.tiff`→tiff, `public.png`→png,
  `public.jpeg`→jpeg, `com.apple.icns`→icns, `com.adobe.pdf`→pdf, `public.svg-image`→svg,
  `public.rtf`→rtf, `public.html`→html, `public.plain-text`→txt ; priorité rtf > txt.
- Format inconnu → aucun fichier n'est créé. Jamais de `.textClipping`.
- Périmètre : dossier personnel récursif (`directoryURLs = [home]`), App Sandbox activée pour
  l'extension (exigence pkd : « plug-ins must be sandboxed »), point d'extension `com.apple.FinderSync`.

## Construire et vérifier

```bash
cd PasteAsFile
swift build -Xswiftc -warnings-as-errors --scratch-path /tmp/pasteasfile-build/spm
swift test  -Xswiftc -warnings-as-errors --scratch-path /tmp/pasteasfile-build/spm   # 15 tests, T1–T14
scripts/verify.sh                                                                   # V1–V5, journalisé
```

Ne construisez pas dans le dossier Google Drive : les attributs `com.apple.FinderInfo` déposés par
Google Drive font échouer la signature (`resource fork, Finder information, or similar detritus
not allowed`). Les scripts écrivent donc les artefacts sur un volume local. Détails et preuves
brutes : `docs/VERDICT.md`.

## Activation

macOS 26 n'enregistre une extension Finder que si le paquet est signé par une identité délivrée par
Apple (Developer ID, ou certificat « Apple Development » obtenu avec votre identifiant Apple dans
Xcode → Settings → Accounts). Sans cette identité, `pluginkit` refuse silencieusement l'appex :
l'extension n'apparaît nulle part, ni dans les Réglages, ni dans le Finder. Le constat et les
quatre expériences qui l'établissent sont dans `docs/VERDICT.md`, ÉTAPE 4.

Procédure, une commande par étape :

```bash
# 1) Build et installation signés (une fois l'identité Apple présente dans le trousseau)
CODE_SIGN_IDENTITY="Apple Development: Prénom Nom (TEAMID)" scripts/build-signed.sh

# 2) Enregistrement et activation sans clic
scripts/activate-extension.sh
```

`activate-extension.sh` exécute `pluginkit -r`/`-a`/`-e use` sur l'appex installé, vérifie l'état
dans `pluginkit -m -A -D`, redémarre le Finder et sort en erreur en expliquant la cause si la
signature n'est toujours pas Apple. Si `pluginkit` a bien enregistré l'extension mais que
l'activation ne tient pas : Réglages Système → Général → Ouverture et extensions → Extensions
Finder → cocher « PasteAsFileFinder », puis relancer le Finder.

## Test d'acceptation

1. Copier une image depuis Safari (clic droit → « Copier l'image »).
2. Dans une fenêtre du Finder, ouvrir un dossier du dossier personnel, clic droit dans le vide de
   la fenêtre → « Coller à partir du presse-papier ».
3. Un fichier `Collé AAAA-MM-JJ à HH.MM.SS.tiff` doit apparaître dans ce dossier.

## Vérifications et limites

- V1–V5 et T1–T14 : tableaux et extraits bruts dans `docs/VERDICT.md`.
- Limite de plateforme (mesurée) : l'enregistrement par `pkd` exige une signature Apple.
- Limite de conception : l'entrée de menu n'apparaît que dans le dossier personnel.
- Le menu contextuel demande un clic dans une zone vide de la fenêtre ou sur un dossier.

## Architecture

- `PasteAsFile/` — application hôte ; `PasteAsFileFinder/` — extension Finder Sync ;
  `PasteAsFileCore/` — logique pure SPM, source partagée avec l'extension ;
  `Tests/PasteAsFileCoreTests/` — tests unitaires ; `scripts/` — vérification, journalisation,
  activation ; `docs/` — plan, arbitrages, verdict et journaux bruts.

## Licence

MIT.

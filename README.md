# PasteAsFile — extension Finder « Coller à partir du presse-papier »

Extension Finder Sync (macOS 13+) ajoutant l'entrée « Coller à partir du presse-papier » au menu
contextuel du Finder, plus l'application hôte qui l'héberge.

![Démonstration PasteAsFile](docs/assets/demo.gif)

- **Guide complet d'utilisation** : [docs/GUIDE-UTILISATEUR.md](docs/GUIDE-UTILISATEUR.md)
- **Rapport de vérification & preuves** : [docs/VERDICT.md](docs/VERDICT.md)

## Dépôt et emplacement (unique)

- Emplacement canonique : `/Users/bf/knowledge-share/projets-dev/PasteAsFile`
- Dépôt GitHub public : https://github.com/bernyforce/PasteAsFile
- Le dépôt a quitté Google Drive le 2026-09-30 : c'est ce qui supprime définitivement les conflits d'attributs `com.apple.FinderInfo` avec la signature.

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

Le dépôt n'est plus dans Google Drive (voir « Dépôt et emplacement ») : les attributs `com.apple.FinderInfo`
déposés par Google Drive faisaient échouer la signature (`resource fork, Finder information, or similar
detritus not allowed`). Les scripts écrivent les artefacts dans `/tmp/pasteasfile-build` puis installent
l'unique exemplaire retenu dans `/Applications`. Détails et preuves brutes : `docs/VERDICT.md`.

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

## Pièges connus

1. **DerivedData et doublons d'enregistrement** : ne jamais laisser Xcode enregistrer un appex résiduel issu de `DerivedData`. En cas d'essai dans Xcode, exécuter systématiquement un *Clean Build Folder* (`Shift + Cmd + K`) pour éviter que `pkd` n'indexe plusieurs copies concurrentes.
2. **Bloc de purge en cas d'entrées multiples** : si des entrées parasites apparaissent dans les Réglages Système ou le menu Finder, exécuter la commande de nettoyage chirurgical :
   ```bash
   rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/PasteAsFile-*
   find /tmp "$HOME/Library/Developer/Xcode/DerivedData" -name "PasteAsFileFinder.appex" 2>/dev/null | while read -r appex; do
       pluginkit -r "$appex" 2>/dev/null || true
   done
   killall pkd Finder 2>/dev/null || true
   /Applications/PasteAsFile.app/Contents/PlugIns/PasteAsFileFinder.appex/Contents/MacOS/PasteAsFileFinder -AppleLanguages '("fr")' 2>/dev/null &
   scripts/activate-extension.sh
   ```
3. **Projet volontairement hors Google Drive** : conserver impérativement le dépôt hors de tout dossier synchronisé Google Drive. Drive dépose des attributs étendus `com.apple.FinderInfo` qui corrompent les signatures de code macOS (`resource fork, Finder information, or similar detritus not allowed`).

## Architecture

- `PasteAsFile/` — application hôte ; `PasteAsFileFinder/` — extension Finder Sync ;
  `PasteAsFileCore/` — logique pure SPM, source partagée avec l'extension ;
  `Tests/PasteAsFileCoreTests/` — tests unitaires ; `scripts/` — vérification, journalisation,
  activation ; `docs/` — plan, arbitrages, verdict et journaux bruts.

## Licence

MIT.

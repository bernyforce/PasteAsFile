# Changelog

## 0.2.0 — 2026-10-01

- Clôture opérationnelle de bout en bout validée par computer use (preuves visuelles dans `docs/logs/gui/`).
- Correction du bac à sable (App Sandbox) : portée FinderSync (`directoryURLs`) redirigée vers le dossier utilisateur réel `/Users/bf` (via `getpwuid` et exception entitlements).
- Nettoyage chirurgical des doublons : 1 seule entrée observée dans Réglages Système et dans le menu contextuel du Finder.
- Validation effective du clic droit : création automatique de fichiers images (`Collé ...png`) et textes (`Collé ...rtf`) à partir du presse-papier.
- Robustesse et non-régression : enregistrement forcé LaunchServices (`lsregister`) et purge automatique (`cleanup_foreign_appex`) dans `build-signed.sh` et `activate-extension.sh` (2 builds consécutifs validés sans doublon).
- Dépôt rendu public sur GitHub avec topics configurés.

## 0.1.3 — 2026-09-30

- Migration définitive hors Google Drive : emplacement `/Users/bf/knowledge-share/projets-dev/PasteAsFile` (copie vérifiée HEAD/arbre identiques, ancien chemin mis à la Corbeille).
- Socle rejoué depuis la nouvelle position : `scripts/verify.sh` rc=0 (8/8), `swift test` 15/15.
- Une seule copie enregistrée par pkd : les scripts suppriment leur produit de scratch après installation.
- Publication : dépôt GitHub privé https://github.com/bernyforce/PasteAsFile (passage public possible via `gh repo edit --visibility public`).
- `com.apple.provenance` documenté comme attribut système inerte (non bloquant pour la signature).

## 0.1.2 — 2026-09-30

- Identité « Apple Development » obtenue via le compte Apple gratuit déjà connecté à Xcode (Personal Team, aucune adhésion payante) : `security find-identity` → `1 valid identities found` (`docs/logs/identity.log`).
- Cause réelle du refus pkd mesurée dans son journal : `plug-ins must be sandboxed` → `com.apple.security.app-sandbox = true` (+ `files.user-selected.read-write`) ; contrôle `V4-sandbox` aligné sur `true`.
- `scripts/build-signed.sh` exécuté avec l'identité Apple : `rc=0`, `TeamIdentifier=7JX62UTF63`, installation dans `/Applications`.
- `scripts/activate-extension.sh` : `rc=0`, extension listée et **activée** par pkd, Finder relancé (`docs/logs/pluginkit.log`).
- Reste à exécuter par l'utilisateur : le test au clic droit (« Coller à partir du presse-papier »).

## 0.1.1 — 2026-09-30

- Reprise de vérification : V1–V5 et T1–T14 verts, chaque statut adossé à une sortie brute dans `docs/logs/`.
- Produits de compilation déplacés hors du dossier Google Drive (`--scratch-path`, DerivedData) : les attributs `com.apple.FinderInfo` posés par Google Drive faisaient échouer la signature.
- `scripts/verify.sh` réécrit : artefacts locaux, journalisation par étape, plus de suppression.
- `scripts/jrn.sh` (journalisation des commandes), `scripts/build-signed.sh` et `scripts/activate-extension.sh` ajoutés.
- ÉTAPE 4 mesurée : `pkd` refuse l'extension non signée par une identité Apple ; cause établie par quatre expériences (`docs/logs/6a`–`6e`).
- `docs/VERDICT.md`, `docs/ARBITRAGES.md` et `README.md` mis à jour sans contradiction.

## 0.1.0 — 2026-09-29

- Projet macOS, extension Finder Sync et package Swift autonome.
- Copie des fichiers, sauvegarde brute des neuf formats prioritaires et nommage local sans écrasement.
- Tests unitaires, intégration NSPasteboard, CI et script de vérification.

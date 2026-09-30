# Changelog

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

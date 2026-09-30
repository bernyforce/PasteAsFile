# PasteAsFile - Dépôt de l'extension Finder pour coller à partir du presse-papier

## Description

Extension Finder Sync qui ajoute une entrée « Coller à partir du presse-papier » au menu contextuel (clic droit) dans le Finder.

## Fonctionnalités

- Si le presse-papier contient des fichiers → les copier dans le dossier ciblé (sans écraser : suffixe " 1", " 2"...).
- Sinon → créer un fichier à partir du contenu brut du presse-papier, SANS conversion (octets écrits tels quels), nommé « Collé AAAA-MM-JJ à HH.MM.SS.ext ».
- Formats prioritaires (UTI → extension) : public.tiff→tiff, public.png→png, public.jpeg→jpeg, com.apple.icns→icns, com.adobe.pdf→pdf, public.svg-image→svg, public.rtf→rtf, public.html→html, public.plain-text→txt.
- Pas de .textClipping : le texte riche est sauvé en .rtf.

## Installation

1. Ouvrir Réglages Système > Confidentialité et sécurité > Extensions Finder
2. Cocher « PasteAsFile »
3. Redémarrer le Finder (ou exécuter `killall Finder`)

## Limitations

- Nécessite macOS 13+ et Xcode 14+
- L'extension est activée pour tous les dossiers, pas uniquement ceux sélectionnés dans la barre de navigation
- Pour l'utilisation du menu contextuel, un dossier doit être sélectionné ou le clic doit être effectué dans le vide

## Tests

Le dépôt contient des tests unitaires qui vérifient :
- La détection des formats prioritaires (T1–T8)
- Le nommage exact « Collé AAAA-MM-JJ à HH.MM.SS.ext » (T10)
- Les collisions avec suffixes 1/2 (T11)
- La préservation octet à octet (T12)
- La copie des fichiers du presse-papier (T13)
- Le traitement du texte riche (T14)

## Architecture

- `PasteAsFile/` — application hôte
- `PasteAsFileFinder/` — extension Finder Sync
- `PasteAsFileCore/` — module SPM avec logique pure testable
- `Tests/PasteAsFileCoreTests/` — tests unitaires

## Licence

MIT

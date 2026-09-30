# PasteAsFile

Application macOS 13+ et extension Finder Sync pour créer un fichier depuis les octets du presse-papiers, ou copier les fichiers déjà copiés dans le Finder. Licence MIT.

## Construire et activer

Prérequis : Xcode 15+ avec licence acceptée, Swift 5.9+, macOS 13+. Aucun paquet tiers requis pour compiler après clonage.

```sh
./scripts/verify.sh
open build/xcode/Build/Products/Release/PasteAsFile.app
```

Dans Xcode, ouvrir `PasteAsFile.xcodeproj`, choisir le schéma `PasteAsFile`, compiler et lancer. Pour une distribution à des tiers, signer l'app et l'extension avec ton identité Apple ; la signature ad hoc locale ne remplace pas une distribution notariée.

Dans Réglages Système > Confidentialité et sécurité > Extensions Finder, cocher PasteAsFileFinder. Redémarrer Finder avec `killall Finder`. L'extension surveille le dossier personnel et ses descendants ; elle ne propose pas le menu sur des volumes hors de ce périmètre. Laisser l'application installée, sinon l'extension embarquée disparaît.

```text
Finder — clic droit dans le vide ou sur dossier
+-----------------------------------------+
| Coller à partir du presse-papier         |
+-----------------------------------------+
             | fichiers -> copies uniques
             + contenu brut -> Collé AAAA-MM-JJ à HH.MM.SS.ext
```

Priorité : TIFF, PNG, JPEG, ICNS, PDF, SVG, RTF, HTML, texte brut. Les données sont enregistrées sans conversion et sans validation du contenu ; un format déclaré mais invalide conserve néanmoins son extension. Les collisions ajoutent ` 1`, ` 2` avant l'extension. Le texte riche devient `.rtf`, jamais `.textClipping`.

## Vérifier

`swift build -Xswiftc -warnings-as-errors --build-path build/spm` ; `swift test -Xswiftc -warnings-as-errors --build-path build/spm` ; `./scripts/verify.sh`. Les preuves et limites de la machine courante figurent dans `docs/VERDICT.md`. `build/` est ignoré par Git.

## Limitations

Finder Sync ne garantit pas une entrée contextuelle universelle hors des dossiers surveillés. L'accès aux dossiers protégés dépend des autorisations macOS. Les erreurs d'écriture et de copie sont consignées dans le journal de l'extension, sans boîte de dialogue. Collisions simultanées non garanties atomiques. Le menu pour sélection multiple de dossiers utilise le premier élément sélectionné. L'intégration visuelle et l'activation doivent être contrôlées manuellement sur un Mac où l'extension est activée.

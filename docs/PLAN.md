# Plan d'exécution

1. Scaffold : dépôt MIT, package Swift, application hôte et cible Finder Sync. Contrôle : structure et métadonnées.
2. Cœur : priorité UTI, noms horodatés, unicité, distinction fichiers/brut. Contrôle : tests unitaires T1–T14.
3. Finder : contexte menu, dossier cible, NSPasteboard et copie sans conversion. Contrôle : compilation des deux cibles.
4. Intégration et CI : fixtures octet à octet, script V1–V5 et workflow macOS. Contrôle : exécution locale.
5. Vérification indépendante : relire les critères, rejouer le script, consigner sorties réelles et limites.
6. Documentation : installation et activation, arbitrages, changelog ; dépôt propre après commit.

Dépendances : 1 → 2 → 3 → 4 → 5 → 6. Une anomalie en 5 revient à l'étape concernée, au plus cinq itérations. Aucun PASS sans preuve réelle.

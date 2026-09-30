# Arbitrages

1. Dossier visé : priorité au dossier sélectionné pour que le clic sur un dossier colle dedans ; sinon dossier ciblé par Finder ; sinon parent de l'élément sélectionné. Ceci corrige la contradiction entre la formule simplifiée `targetedURL() ?? parent` et la demande « sur un dossier ».
2. Extension limitée au dossier personnel récursif, conformément à `directoryURLs = [home]` fourni. Finder Sync ne couvre pas tous les volumes par défaut.
3. La logique du package Swift est compilée également comme source partagée de l'extension Xcode, sans dépendance externe ou duplication de règles.
4. Les formats inconnus ne créent aucun fichier. Une représentation UTI présente est écrite telle quelle, même si son contenu est invalide ; aucune conversion ni sniffing.
5. Signature ad hoc (`-`) pour usage local ; la distribution nécessite une signature d'identité et la notarisation. Sandbox extension explicitement désactivée comme demandé.
6. Le repo se trouve dans un sous-dossier `PasteAsFile` du répertoire courant ; aucun push GitHub ni publication n'a été demandé.
7. Licence Xcode locale non acceptée : aucune acceptation au nom de l'utilisateur ; verdict des commandes bloquées marqué NON VÉRIFIÉ, jamais PASS de convenance.

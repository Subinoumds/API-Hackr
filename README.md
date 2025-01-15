Installer : 

* Ruby (version >= 3.2.2)
* Yarn (gestionnaire de paquets) (npm install -g yarn)
* PostgreSQL (base de données)


Une fois le repo cloné, exécuter :
 bundle install

Puis : 
 yarn install

Configurer la bdd en créant un fichier .env

Modifie le fichier .env pour ajouter ses identifiants PostgreSQL (username et password).

Ensuite seter la bdd de l’api en exécutant : 
 « rails db:create » 
Et ensuite « rails db:migrate »


Et enfin pour démarrer l’api : 

Exécuter « rails s »

L'API sera disponible sur : http://localhost:3000

Utilisation de l'API avec Postman

Utiliser le fichier .json disponible afin de retrouver tous les endpoints déjà rédigés et prêts à être testées 



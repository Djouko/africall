# Deploiement Easypanel - AfriCall / Sonivo AI

Ce projet se deploie depuis la racine du depot GitHub avec le `Dockerfile`.
Le frontend React recupere est maintenant integre dans `upload_this/client/public` et le backend Node le sert directement.

## Etat actuel du projet

- Backend Node/Express: `upload_this/server.js`
- Frontend React compile: `upload_this/client/public`
- Builder Easypanel recommande: Dockerfile
- Dockerfile path: `Dockerfile`
- Port interne de l'application: `8001`
- Healthcheck Docker: `/api/web/get_theme`
- Base de donnees: MySQL

## Variables d'environnement Easypanel

Configurer ces variables dans l'onglet **Environnement** du service `app`.
Ne jamais commiter de fichier `.env`.

```env
HOST=0.0.0.0
PORT=8001
DBHOST=<host_mysql_easypanel>
DBPORT=3306
DBNAME=u214573487_ai_call_center
DBUSER=<user_mysql>
DBPASS=<password_mysql>
JWTKEY=<long_secret_random>
FRONTENDURI=https://<votre-domaine-app>
BACKURI=https://<votre-domaine-app>
BEEPSOURCE=
```

Notes:

- `HOST` doit etre `0.0.0.0` en conteneur.
- `PORT` doit rester `8001`, comme dans le Dockerfile.
- `FRONTENDURI` et `BACKURI` doivent utiliser le domaine public final en HTTPS.
- `JWTKEY` doit etre une longue chaine aleatoire et secrete.

## Service MySQL

Dans Easypanel, creer un service MySQL dans le meme projet, puis importer le fichier SQL fourni par le vendeur.
Le fichier attendu est generalement dans le dossier `database/`, par exemple `database/install.sql`.

Si Easypanel affiche une erreur MySQL 8 de type `ER_NOT_SUPPORTED_AUTH_MODE`, le code utilise maintenant `mysql2`, ce qui corrige le client Node. Si l'erreur revient, verifier surtout les identifiants et l'hote MySQL configures dans l'environnement.

## Service app

Configuration recommandee:

```text
Source: GitHub repository
Repository: Djouko/africall
Branch: main
Builder: Dockerfile
Dockerfile path: Dockerfile
Proxy port: 8001
```

Pour une application web, utiliser **Domains & Proxy**. L'onglet **Ports** sert surtout aux applications non-web.

```text
Domain: <votre-domaine-ou-sous-domaine>
Proxy Port: 8001
HTTPS: enabled
```

Easypanel construit l'image depuis le Dockerfile si le depot en contient un. Les variables de l'onglet **Environnement** sont disponibles au build-time et au run-time.

## Verification apres deploiement

Tester dans le navigateur:

```text
https://<votre-domaine>/
https://<votre-domaine>/admin
https://<votre-domaine>/api/web/check_install
https://<votre-domaine>/api/web/get_theme
```

Resultats attendus:

- `/` affiche le frontend React, sans redirection Envato.
- `/admin` affiche l'application React via le fallback Express.
- `/api/web/check_install` retourne `{"success":true}`.
- `/api/web/get_theme` retourne un JSON avec `success: true`.

## Comptes initiaux

Comptes souvent presents apres import de la base vendeur:

```text
Admin: admin@admin.com / password
User: user@user.com / password
```

Changer ces mots de passe immediatement apres le premier acces.

## Tests fonctionnels minimum

1. Ouvrir `/admin`.
2. Se connecter comme admin.
3. Aller dans les reglages de configuration.
4. Verifier que `FRONTENDURI` et `BACKURI` correspondent au domaine HTTPS final.
5. Ouvrir le dashboard utilisateur.
6. Verifier que les menus principaux se chargent: dashboard, phonebook, devices, agents, IVR, campaigns, SMS.
7. Tester une creation simple non payante: contact, phonebook ou agent interne.
8. Ne tester Twilio/appels reels qu'apres configuration officielle des cles Twilio.

## Diagnostic rapide

Si le domaine affiche `Service is not reachable`:

1. Verifier que le service `app` a au moins `1 / 1` replica en execution.
2. Ouvrir les logs du service `app`.
3. Chercher `Whatsham server is running on port 8001`.
4. Verifier que le domaine pointe vers `http://<service>:8001/` dans Domains & Proxy.
5. Ouvrir `/api/web/get_theme`; si cette route ne repond pas, regarder la connexion MySQL.

Si le frontend charge mais les actions API echouent:

1. Verifier `FRONTENDURI` et `BACKURI`.
2. Verifier que le domaine utilise HTTPS.
3. Ouvrir la console navigateur et chercher les erreurs CORS/API.
4. Verifier les logs backend dans Easypanel.
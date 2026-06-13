# Deploiement Easypanel

Ce projet se deploie depuis la racine du depot avec le `Dockerfile`.

## Service applicatif

- Builder: Dockerfile
- Dockerfile path: `Dockerfile`
- Port expose par le conteneur: `8001`
- Health check simple: ouvrir `/api/web/get_theme`

## Variables d'environnement

Configurer ces variables dans Easypanel, sans commiter de fichier `.env`:

```env
HOST=0.0.0.0
PORT=8001
DBHOST=<host_mysql_easypanel>
DBPORT=3306
DBNAME=u214573487_ai_call_center
DBUSER=<user_mysql>
DBPASS=<password_mysql>
JWTKEY=<long_secret_random>
FRONTENDURI=https://<votre-domaine>
BACKURI=https://<votre-domaine>
BEEPSOURCE=
```

## Base MySQL

Creer une base MySQL dans Easypanel, puis importer:

```text
database/install.sql
```

Comptes initiaux:

- Admin: `admin@admin.com` / `password`
- User: `user@user.com` / `password`

Changer ces mots de passe apres le premier acces.

## Point important

Le dossier `upload_this/client/public` contient actuellement une page de redirection vers le portail de verification Envato. Le backend se lance correctement, mais le vrai frontend doit etre fourni/debloque par le support ou le portail de verification du vendeur.

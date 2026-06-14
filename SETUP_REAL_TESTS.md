# AfriCall - setup du premier test reel

Ce guide part du principe que l'application AfriCall fonctionne deja en local et sur Easypanel. L'objectif ici est de connecter les services externes minimaux pour faire un premier test reel de bout en bout : appel entrant, appel sortant navigateur, SMS entrant/sortant, IVR, agent vocal IA et logs.

## 1. Pre-requis

- Application deployee en HTTPS avec un domaine stable.
- Variables Easypanel `FRONTENDURI` et `BACKURI` pointees vers ce domaine HTTPS.
- Base MySQL connectee et application accessible.
- Compte Twilio actif.
- Un numero Twilio avec capacites Voice et, si possible, SMS.
- Un numero telephone personnel pour tester.
- Si le compte Twilio est encore en trial : le numero destinataire doit etre verifie dans Twilio.
- Un compte OpenAI ou ElevenLabs uniquement si le test IA vocale est lance. Pour un premier test telecom pur, l'IVR simple suffit.

## 2. Variables Easypanel a verifier

Dans Easypanel, ouvrir le service `app`, puis `Environnement`.

Verifier :

```env
HOST=0.0.0.0
PORT=8001
FRONTENDURI=https://votre-domaine
BACKURI=https://votre-domaine
DBHOST=mysql
DBPORT=3306
DBNAME=<nom_base>
DBUSER=<user_base>
DBPASS=<mot_de_passe_base>
JWTKEY=<chaine_longue_secrete>
```

Apres chaque modification d'environnement, redeployer le service `app`.

## 3. Creer les informations Twilio

### 3.1 Recuperer Account SID et Auth Token

1. Ouvrir `https://console.twilio.com`.
2. Aller dans `Account` puis `API keys & tokens`.
3. Copier `Account SID`.
4. Copier `Auth Token`.
5. Garder ces valeurs dans un gestionnaire de secrets, pas dans un document public.

### 3.2 Creer une API Key Twilio

1. Dans `API keys & tokens`, cliquer `Create API key`.
2. Choisir le type `Standard`.
3. Nommer la cle `AfriCall Browser Voice`.
4. Cliquer `Create API Key`.
5. Copier immediatement :
   - `SID` : ce sera `api_key` dans AfriCall.
   - `Secret` : ce sera `api_secret` dans AfriCall.
6. Stocker le secret tout de suite. Twilio ne le reaffiche plus apres.

### 3.3 Acheter ou choisir un numero Twilio

1. Aller dans `Phone Numbers`.
2. Ouvrir `Manage` puis `Buy a number`.
3. Filtrer un numero avec capacite `Voice`.
4. Ajouter aussi `SMS` si le pays et le numero le permettent.
5. Acheter le numero.
6. Noter le numero au format E.164, par exemple `+15551234567`.

Pour le premier test depuis le Cameroun, il est possible qu'un numero local camerounais ne soit pas disponible directement. Le test peut commencer avec un numero Twilio disponible, puis la strategie "appels gratuits pour le client" devra etre traitee via numero local/toll-free disponible, operateur local, SIP trunk ou partenariat telecom.

### 3.4 Verifier le numero destinataire si Twilio est en trial

1. Aller dans `Phone Numbers`.
2. Ouvrir `Verified Caller IDs`.
3. Cliquer `Add a new Caller ID`.
4. Entrer le numero personnel de test.
5. Valider le code recu par SMS.

Un compte trial ne permet pas de contacter librement tous les numeros. Pour un test propre, verifier d'abord le numero qui recevra les appels et SMS.

## 4. Creer la TwiML App pour les appels navigateur

La TwiML App est obligatoire pour que le navigateur puisse appeler via le SDK Twilio Voice. AfriCall stocke son SID dans le champ `outgoing_app_sid` du Device.

1. Dans Twilio Console, aller dans `Explore Products`.
2. Ouvrir `Voice`.
3. Aller dans `TwiML Apps`.
4. Cliquer `Create new TwiML App`.
5. Friendly name : `AfriCall Browser Dialer`.
6. `Voice Request URL` provisoire :

```text
https://votre-domaine/api/call/voice/pending
```

7. Methode : `HTTP POST`.
8. Enregistrer.
9. Copier le `TwiML App SID`, qui commence par `AP`.

La route finale depend du `device_id`, qui n'existe qu'apres la creation du Device AfriCall. On corrigera donc l'URL apres l'etape suivante.

## 5. Creer le Device dans AfriCall

1. Ouvrir l'application AfriCall.
2. Se connecter avec un compte utilisateur actif.
3. Aller dans la zone `Devices` ou `Device Number Management`.
4. Cliquer sur l'action d'ajout de device.
5. Renseigner :
   - `Title` : `Twilio Test Principal`
   - `SID` : Account SID Twilio, commence par `AC`
   - `Token` : Auth Token Twilio
   - `API Key` : SID de l'API Key, commence par `SK`
   - `API Secret` : secret de l'API Key
   - `Outgoing App SID` : SID de la TwiML App, commence par `AP`
   - `Number` : numero Twilio au format international. Si l'interface refuse le `+`, entrer les chiffres avec indicatif pays.
6. Enregistrer.
7. Revenir sur la liste des devices.
8. Copier les URLs affichees par AfriCall, surtout :
   - SMS : `https://votre-domaine/api/message/msg/<device_id>`
   - IVR : `https://votre-domaine/api/ivr/gather/<device_id>`
   - Dial out : `https://votre-domaine/api/call/voice/<device_id>`
   - Voice Agent : `https://votre-domaine/api/vagent/incoming/<device_id>`

## 6. Mettre a jour la TwiML App

1. Retourner dans Twilio Console.
2. Aller dans `Voice` puis `TwiML Apps`.
3. Ouvrir `AfriCall Browser Dialer`.
4. Remplacer `Voice Request URL` par :

```text
https://votre-domaine/api/call/voice/<device_id>
```

5. Methode : `HTTP POST`.
6. Enregistrer.

## 7. Configurer le numero Twilio

1. Aller dans `Phone Numbers`.
2. Ouvrir `Manage` puis `Active numbers`.
3. Cliquer sur le numero Twilio achete.
4. Dans `Voice Configuration`, choisir `Webhook`.
5. Pour un premier test simple, mettre :

```text
https://votre-domaine/api/ivr/gather/<device_id>
```

6. Methode : `HTTP POST`.
7. Enregistrer.
8. Dans `Messaging Configuration`, mettre :

```text
https://votre-domaine/api/message/msg/<device_id>
```

9. Methode : `HTTP POST`.
10. Enregistrer.

Pour tester l'agent vocal IA en entree, remplacer ensuite le webhook Voice par :

```text
https://votre-domaine/api/vagent/incoming/<device_id>
```

## 8. Configurer un premier IVR simple

1. Dans AfriCall, ouvrir `IVR` ou `Call Flow Builder`.
2. Selectionner le device Twilio.
3. Activer l'IVR.
4. Creer un flux minimal :
   - Message de bienvenue.
   - Menu DTMF : `1` pour parler a un agent, `2` pour laisser un message ou entendre une information.
   - Une route de fin claire.
5. Enregistrer le flow.
6. Faire un appel entrant vers le numero Twilio.

Resultat attendu : Twilio appelle `POST /api/ivr/gather/<device_id>`, AfriCall renvoie du TwiML, le menu vocal se joue, puis les logs apparaissent dans l'application.

## 9. Configurer l'agent vocal IA

Le module IA vocale utilise Twilio Media Streams en WebSocket via :

```text
wss://votre-domaine/api/vagent/media-stream
```

La route d'appel entrant IA est :

```text
https://votre-domaine/api/vagent/incoming/<device_id>
```

Etapes :

1. Dans AfriCall, ouvrir la section `Voice Agent`.
2. Creer un flow IA minimal.
3. Ajouter un noeud de depart IA.
4. Choisir le fournisseur voix :
   - `ElevenLabs` pour une voix plus humaine.
   - `OpenAI` pour un test realtime si le compte API a acces au modele vocal.
5. Ajouter la cle API correspondante dans le flow ou les reglages prevus par l'interface.
6. Activer l'agent pour le device.
7. Route : `incoming`.
8. Enregistrer.
9. Dans Twilio, remplacer le webhook Voice du numero par `https://votre-domaine/api/vagent/incoming/<device_id>`.
10. Appeler le numero Twilio.

Pour le contexte camerounais, commencer par francais simple, puis ajouter progressivement anglais, pidgin, fulfulde, ewondo, duala, bassa, ghomala ou autres langues selon le marche cible. La qualite dependra des modeles STT/TTS disponibles pour chaque langue.

## 10. Tester les SMS

### SMS entrant

1. Depuis le telephone de test, envoyer un SMS au numero Twilio.
2. Verifier dans AfriCall que le message apparait dans `SMS Manager`.
3. Verifier les logs Twilio si rien n'arrive.

Webhook attendu :

```text
POST https://votre-domaine/api/message/msg/<device_id>
```

### SMS sortant

1. Dans AfriCall, ouvrir `SMS Manager`.
2. Choisir le device Twilio.
3. Envoyer un SMS au numero verifie.
4. Verifier la reception sur le telephone.
5. Si erreur Twilio `21408`, activer le pays destinataire dans `Messaging Geographic Permissions`.

## 11. Tester les appels sortants navigateur

1. Verifier que le navigateur autorise le micro.
2. Dans AfriCall, ouvrir le module d'appel ou dialer.
3. Choisir le device Twilio.
4. Composer le numero personnel de test en E.164.
5. Lancer l'appel.

Resultat attendu :

- Le front demande un token a `POST /api/call/gen_twilio_token`.
- Le SDK Twilio Voice utilise la TwiML App.
- Twilio appelle `POST /api/call/voice/<device_id>`.
- AfriCall renvoie le TwiML de dial.
- Le telephone sonne.
- Le log d'appel est visible.

## 12. Premier scenario complet recommande

Faire les tests dans cet ordre :

1. Ouvrir `https://votre-domaine/api/web/check_install`.
2. Verifier que l'application charge en HTTPS.
3. Creer ou verifier un utilisateur actif avec plan valide.
4. Ajouter le Device Twilio.
5. Tester SMS entrant.
6. Tester SMS sortant vers un numero verifie.
7. Tester appel sortant navigateur vers un numero verifie.
8. Configurer IVR simple.
9. Tester appel entrant vers le numero Twilio.
10. Activer Voice Agent sur le meme device.
11. Remplacer le webhook Voice par `/api/vagent/incoming/<device_id>`.
12. Tester un appel IA court.
13. Verifier les logs AfriCall.
14. Verifier Twilio Console > Monitor > Logs > Calls et Messaging.
15. Faire une mini-campagne avec un seul contact verifie.

## 13. Points de vigilance avant production

- Ne jamais lancer une campagne sur de vrais clients sans consentement explicite.
- Garder une liste d'exclusion et respecter les opt-out.
- Ne pas exposer `Auth Token`, `API Secret`, `JWTKEY`, `.env` ou dumps SQL.
- Utiliser HTTPS public stable pour Twilio.
- Les webhooks Twilio devraient etre proteges par validation `X-Twilio-Signature`. Le projet actuel recoit les webhooks, mais une verification de securite dediee est a faire avant production ouverte.
- Les appels "gratuits pour le client" ne sont pas automatiques. En pratique, un appelant peut payer selon son operateur si le numero n'est pas local/toll-free. Pour le Cameroun, il faudra etudier les options operateur local, toll-free disponible, SIP trunk local ou partenariat telecom.
- Tester d'abord avec un seul numero, puis cinq, puis dix, avant toute campagne.
- Surveiller les couts Twilio et les permissions pays.

## 14. Routes confirmees dans le code

| Besoin | URL AfriCall | Methode |
| --- | --- | --- |
| SMS entrant Twilio | `/api/message/msg/<device_id>` | POST |
| Envoi SMS depuis app | `/api/message/send_sms` | POST authentifie |
| Token Twilio navigateur | `/api/call/gen_twilio_token` | POST authentifie |
| Appel sortant navigateur | `/api/call/voice/<device_id>` | POST |
| Recording callback | `/api/call/voice/record` | POST |
| IVR entrant | `/api/ivr/gather/<device_id>` | POST |
| Reponse IVR Gather | `/api/ivr/reply` | POST |
| Voice Agent entrant | `/api/vagent/incoming/<device_id>` | ALL |
| Voice Agent sortant | `/api/vagent/outgoing-connect/<device_id>` | ALL |
| Media Stream IA | `/api/vagent/media-stream` | WebSocket |
| Statut conference IA | `/api/vagent/conference-status` | POST |


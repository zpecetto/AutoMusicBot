# AutoMusicBot

Workflows n8n pour traiter une playlist YouTube, convertir l’audio en MP3 sur l’hôte, envoyer les fichiers sur Google Drive, puis retirer les éléments traités de la playlist. Un second workflow propose des recommandations musicales avec Ollama et un outil Google Drive.

## Fichiers

| Fichier | Rôle |
|---|---|
| [Musique.json](Workflow/Musique.json) | Partie Playlist extraite d’Ultime, avec le démarrage commun et les boucles, 18 nœuds |
| [Conseille Musique.json](Workflow/Conseille%20Musique.json) | Version actualisée avec Google Drive Tool et comptage des fichiers audio, 15 nœuds |
| [download_music.sh](download_music.sh) | Validation de l’identifiant vidéo, cookies facultatifs, Deno, ffmpeg et conversion MP3 |
| [docker-compose.yml](docker-compose.yml) | Configuration n8n/Ollama issue du compose fourni, avec montage du dossier audio et réglages de durée d’exécution |

## Installation

1. Placer ce dépôt dans `~/AutoMusicBot` sur la machine accessible par les credentials SSH de n8n. Si le chemin diffère, adapter **Téléchargement Musique**.
2. Installer [yt-dlp](https://github.com/yt-dlp/yt-dlp#installation), Deno et ffmpeg sur cette machine. Le script utilise `/usr/local/bin/yt-dlp` par défaut, modifiable avec la variable `YTDLP`.
3. Exécuter `chmod +x download_music.sh` puis créer le dossier `Musique` à côté du script. n8n doit pouvoir lire les fichiers créés dans ce dossier.
4. Pour une nouvelle installation, copier `.env.example` vers `.env`, adapter les valeurs et lancer `docker compose up -d`. Si n8n existe déjà, reprendre uniquement les montages et réglages nécessaires.
5. Vérifier que le dossier de sortie du script et `MUSIC_HOST_DIR` désignent le même dossier sur l’hôte. Il est monté dans n8n sous `/home/node/.n8n-files`.

Les services Browserless, Audible et Watchtower du compose personnel ne sont pas nécessaires à ces deux workflows et ne sont pas inclus dans ce compose dédié. Le volume n8n est créé par défaut ; adapter sa déclaration pour réutiliser un volume existant.

## Configuration des workflows

1. Importer les deux JSON. Ils sont désactivés et ne contiennent aucun credential personnel.
2. Dans **Configuration Globale**, remplacer `Playlist_youtube`. Le nœud **Playlist** lit cette valeur.
3. Sélectionner les credentials YouTube, Google Drive, SSH, Telegram et Ollama dans leurs nœuds respectifs.
4. Remplacer `YOUR_MUSIC_FOLDER_ID` dans **Upload file** par le dossier de destination. Dans le workflow de conseil, configurer le dossier du catalogue musical dans les deux nœuds Google Drive ; il peut être différent du dossier de destination.
5. Configurer le destinataire Telegram de la synchronisation. Le conseiller répond au chat reçu par son propre Telegram Trigger.
6. Adapter le début commun : **Schedule Trigger → Date & Time → Configuration Globale → Loop Over Items4 → HTTP Request1 → If5**. L’URL de contrôle, la restauration ngrok en SSH, **Wait1** et le retour dans la boucle sont conservés.
7. Le planificateur reprend le vendredi à 17 h. Adapter l’horaire et le fuseau. Le conseiller conserve son déclencheur Telegram et le modèle `llama3.2:latest` de l’export.
8. Vérifier un téléchargement et un envoi sur Drive avant activation. **Delete a playlist item** est exécuté après **Upload file** et retire l’entrée de la playlist.

Le nœud **Éteindre Tunnel** termine la branche musique par `pkill ngrok`, comme dans la source. Désactiver ou adapter ce nœud si d’autres workflows partagent ce tunnel. Ne pas lancer simultanément cette extraction et la branche musique du workflow Ultime sur la même playlist.

## Script de téléchargement

Les chemins personnels sont remplacés par des valeurs portables :

| Variable | Valeur par défaut |
|---|---|
| `YTDLP` | `/usr/local/bin/yt-dlp` |
| `OUTPUT_DIR` | Dossier `Musique` à côté du script |
| `COOKIE_FILE` | Fichier `youtube-cookies.txt` à côté du script |

Le cookie YouTube, s’il est nécessaire, doit être un fichier local au format accepté par yt-dlp et rester privé. Son absence n’empêche pas de traiter les vidéos accessibles sans connexion.

La sortie `N8N_FILE:` contient le chemin final encodé en JSON, produit par l’option `--print` après conversion. Le nœud Code le traduit en chemin dans le conteneur. Il signale une erreur si le téléchargement échoue ou si aucun MP3 n’est retourné, y compris lors du retraitement d’un fichier existant.

## Vérification

Les connexions et références des workflows, le JavaScript, les expressions et la syntaxe Bash sont contrôlés localement. Des tests simulés vérifient le chemin audio et le refus des sorties invalides. Aucun téléchargement, envoi Drive, retrait de playlist ni message Telegram réel n’a été exécuté pendant la préparation.

Les quotas YouTube s’appliquent aux opérations de playlist. Les fichiers et données de catalogue envoyés à Google Drive ou Telegram quittent la machine locale ; seul le modèle Ollama s’exécute localement avec cette configuration.

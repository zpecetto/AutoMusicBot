# 🎵 AutoMusicBot : Downloader YouTube & Recommandation IA

Un système d'automatisation complet géré par **n8n** permettant de télécharger automatiquement des musiques depuis une playlist YouTube, de les sauvegarder sur Google Drive, de nettoyer la playlist, et de se faire conseiller de nouveaux titres par un Agent IA.

L'architecture a été pensée et optimisée pour tourner en local sur un **Raspberry Pi 5 (16Go RAM)** via Docker.

## ✨ Fonctionnalités

* **📥 Téléchargement Automatique (yt-dlp) :** Surveille une playlist YouTube spécifique. Dès qu'une vidéo y est ajoutée, le système utilise un script bash `yt-dlp` pour télécharger l'audio en MP3 haute qualité de manière invisible.
* **☁️ Sauvegarde Cloud & Nettoyage :** Le fichier MP3 généré est automatiquement uploadé sur votre Google Drive. Une fois la sauvegarde confirmée, la vidéo est supprimée de la playlist YouTube pour garder une file d'attente propre.
* **🤖 Agent IA Musical (Local) :** Un bibliothécaire musical (LLM) propulsé par Ollama.
  * Il possède un outil (`liste_musiques`) pour fouiller dans les musiques que vous possédez déjà.
  * S'il veut vous recommander une nouveauté, il vérifie d'abord silencieusement dans votre base de données que vous ne l'avez pas déjà avant de vous la proposer.

## 🛠️ Stack Technique

* **Orchestrateur :** n8n (avec l'exécution de commandes système activée `N8N_COMMAND_EXECUTION_ENABLED=true`).
* **Moteur de téléchargement :** `yt-dlp` exécuté via un script Bash.
* **IA Local :** Ollama (LLM) & Langchain Agents.
* **Infrastucture :** Docker & Docker Compose.
* **APIs :** YouTube Data API v3 & Google Drive API.

---

## ⚙️ Installation & Configuration

### 1. Prérequis sur la machine hôte
Le script de téléchargement fait appel à `yt-dlp`. Assurez-vous qu'il est installé sur votre machine hôte (ex: Raspberry Pi) au chemin exact `/usr/local/bin/yt-dlp`.
```bash
sudo curl -L [https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp](https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp) -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp

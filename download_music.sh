#!/bin/bash
# Télécharge l'URL ($1) en MP3 haute qualité dans le dossier monté par Docker
/usr/local/bin/yt-dlp -x --audio-format mp3 --audio-quality 0 -o "/home/node/.n8n-files/%(title)s.%(ext)s" "$1"
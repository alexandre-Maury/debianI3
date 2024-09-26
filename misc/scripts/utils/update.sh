#!/bin/bash

# Activer le mode strict pour le script
set -euo pipefail
IFS=$'\n\t'
# Plus d'informations : http://redsymbol.net/articles/unofficial-bash-strict-mode/

# Naviguer dans le répertoire du dépôt
cd /opt/debianI3 || { echo "Erreur : impossible de se rendre dans le répertoire /opt/debianI3"; exit 1; }

# Vérifier les mises à jour du dépôt distant
git fetch

# Récupérer les versions locales et distantes
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

# Si des mises à jour sont disponibles, demander à l'utilisateur s'il souhaite mettre à jour
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Une mise à jour est disponible pour Ubuntu."
    while true; do
        read -r -p "Souhaitez-vous mettre à jour ? [O/n] " response
        case "$response" in
            [Oo]* | "" )  # 'O' ou 'o' pour Oui, ou entrée par défaut
                git pull
                bash -x install.sh
                echo "Ubuntu a été mis à jour."
                break
                ;;
            [Nn]* )  # 'N' ou 'n' pour Non
                echo "Mise à jour annulée."
                exit 0
                ;;
            * )  # Gérer les réponses incorrectes
                echo "Veuillez répondre par O ou n."
                ;;
        esac
    done
else
    echo "Le système est déjà à jour 🌹"
fi

# - name: Fusionner le dossier de configuration avec $HOME/.config
#   hosts: localhost
#   tasks:
#     - name: Copier et fusionner les fichiers avec rsync
#       ansible.builtin.command:
#         cmd: rsync -av --delete /opt/debianI3/misc/dotfiles/config/ {{ ansible_env.HOME }}/.config/
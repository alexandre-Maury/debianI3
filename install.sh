#!/bin/bash

# Activer le mode strict de Bash pour une meilleure gestion des erreurs
set -euo pipefail

# Définir l'IFS (Internal Field Separator) pour gérer correctement les espaces blancs
IFS=$'\n\t'

# Fonction pour afficher les messages de statut
# Fonction pour afficher les messages de statut jaune
status_message_system() {
    echo -e "\033[0;33m [*] $1 \033[0m"
}  

# Fonction pour afficher les messages d'erreur rouge
status_message_error() {
    echo -e "\033[0;31m [-] $1 \033[0m"
}

# Fonction pour afficher les messages de succés vert
status_message_succes() {
    echo -e "\033[0;32m [+] $1 \033[0m"
}

# Vérifier si l'utilisateur courant est root
if [ "$(whoami)" == "root" ]; then
    status_message_error "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
    exit 1  # Quitte le script avec un code d'erreur
fi

# Vérifier si l'utilisateur est dans le groupe sudo
if ! groups "$(whoami)" | grep -q "\bsudo\b"; then
    status_message_error "L'utilisateur $(whoami) n'est pas dans le groupe sudo."
    exit 1  # Quitte le script avec un code d'erreur
fi

export PATH="$HOME/.local/bin:$PATH"

# Vérification si Ansible est déjà installé
if ! command -v ansible &> /dev/null
then

    # Mise à jour des paquets du système et installation des outils de base
    status_message_system "Ansible n'est pas installé. Installation en cours..."
    
    status_message_system "Configuration du DNS pour utiliser le serveur DNS de Quad9"
    echo "nameserver 9.9.9.9" | sudo tee /etc/resolv.conf

    # Nettoyer le cache des paquets, mettre à jour la liste et les paquets
    # sudo rm -v /var/cache/apt/archives/lock
    DEBIAN_FRONTEND=noninteractive sudo apt clean
    DEBIAN_FRONTEND=noninteractive sudo apt update
    DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y
    DEBIAN_FRONTEND=noninteractive sudo apt autoremove -y

    sudo apt install pipx -y

    pipx ensurepath --force 

    # Installer Ansible-core avec pipx
    pipx install ansible-core --force

    # Installer la collection Ansible 'community.general'
    ansible-galaxy collection install community.general

    status_message_succes "Ansible a été installé avec succès ..."

else
    status_message_system "Ansible est déjà installé ..."
    
fi



ansible-playbook -vvv -i inventory.ini --ask-become main.yml 


clear

status_message_succes "Installation Terminée :"
status_message_system " === CONFIGURATION DE YouCompleteMe === "
status_message_system " Instructions d'installation ===> Aprés Installation des pluggins <run : vim>"
status_message_system " 1. Navigue vers le répertoire YouCompleteMe :"
status_message_system "    cd ~/.vim/plugged/YouCompleteMe"
status_message_system " 2. Compile avec la commande :"
status_message_system "    python3 install.py --clangd-completer"
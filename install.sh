#!/bin/bash

# Activer le mode strict de Bash pour une meilleure gestion des erreurs
set -euo pipefail

# Définir l'IFS (Internal Field Separator) pour gérer correctement les espaces blancs
IFS=$'\n\t'

# Fonction pour afficher les messages de statut
status_message() {
    echo "[*] $1"
}  

# Vérifier si l'utilisateur courant est root
if [ "$(whoami)" == "root" ]; then
    status_message "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
    exit 1  # Quitte le script avec un code d'erreur
fi

# Vérifier si l'utilisateur est dans le groupe sudo
if ! groups "$(whoami)" | grep -q "\bsudo\b"; then
    echo "Erreur : L'utilisateur $(whoami) n'est pas dans le groupe sudo."
    exit 1  # Quitte le script avec un code d'erreur
fi

export PATH="$HOME/.local/bin:$PATH"

# Vérification si Ansible est déjà installé
if ! command -v ansible &> /dev/null
then

    # Mise à jour des paquets du système et installation des outils de base
    status_message "Ansible n'est pas installé. Installation en cours..."
    
    status_message "Configuration du DNS pour utiliser le serveur DNS de Quad9"
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

    status_message "Ansible a été installé avec succès ..."

else
    status_message "Ansible est déjà installé ..."
    
fi



ansible-playbook -vvv -i inventory.ini --ask-become main.yml 


clear

echo "Installation Terminée :"

echo " === CONFIGURATION DE YouCompleteMe === "
echo " Instructions d'installation ===> Aprés Installation des pluggins <run : vim>"
echo " 1. Navigue vers le répertoire YouCompleteMe :"
echo "    cd ~/.vim/plugged/YouCompleteMe"
echo " 2. Compile avec la commande :"
echo "    python3 install.py --clangd-completer"
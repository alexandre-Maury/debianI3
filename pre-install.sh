#!/bin/bash

# Activer le mode strict de Bash pour une meilleure gestion des erreurs
set -euo pipefail

# Définir l'IFS (Internal Field Separator) pour gérer correctement les espaces blancs
IFS=$'\n\t'

# Fonction pour afficher les messages de statut
status_message() {
    echo "[*] $1"
}  

# Obtenir l'utilisateur courant
read -p "[*] Veuillez entrer votre nom d'utilisateur pour la suite du script : " USER_TO_ADD


# Vérifier si l'utilisateur est déjà dans le groupe sudo
if groups "$USER_TO_ADD" | grep -q "\bsudo\b"; then
    echo "$USER_TO_ADD est déjà dans le groupe sudo."

else
    echo "$USER_TO_ADD n'est pas dans le groupe sudo. Ajout en cours..."
    #ansible-playbook ~/add_user_to_sudo.yml -e "user_to_add=$USER_TO_ADD"

    usermod -aG sudo $USER_TO_ADD
    printf "%s \\n" "[Succès] Votre compte : ${USER_TO_ADD} est à présent membre du groupe sudo"
fi


# Vérification si Ansible est déjà installé
if ! command -v ansible &> /dev/null
then

    # Mise à jour des paquets du système et installation des outils de base
    status_message "Ansible n'est pas installé. Installation en cours..."
    
    status_message "Configuration du DNS pour utiliser le serveur DNS de Quad9"
    echo "nameserver 9.9.9.9" | tee /etc/resolv.conf

    # Nettoyer le cache des paquets, mettre à jour la liste et les paquets
    # sudo rm -v /var/cache/apt/archives/lock
    DEBIAN_FRONTEND=noninteractive apt clean
    DEBIAN_FRONTEND=noninteractive apt update
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
    DEBIAN_FRONTEND=noninteractive apt autoremove -y

    # Installer la collection Ansible 'community.general'
    ansible-galaxy collection install community.general

    status_message "Ansible a été installé avec succès ..."

else
    status_message "Ansible est déjà installé ..."
    
fi

apt install pipx -y

export PIPX_HOME="/home/$USER_TO_ADD/.local/pipx"
export PIPX_BIN_DIR="/home/$USER_TO_ADD/.local/bin"
pipx ensurepath --force 

# Installer Ansible-core avec pipx
pipx install ansible-core --force

ansible-playbook -vvv -i inventory.ini --ask-become main.yml -e "user_env=$USER_TO_ADD"


clear

echo "Installation Terminée :"

echo " === CONFIGURATION DE YouCompleteMe === "
echo " Instructions d'installation ===> Aprés Installation des pluggins <run : vim>"
echo " 1. Navigue vers le répertoire YouCompleteMe :"
echo "    cd ~/.vim/plugged/YouCompleteMe"
echo " 2. Compile avec la commande :"
echo "    python3 install.py --clangd-completer"
#!/bin/bash

# Activer le mode strict de Bash pour une meilleure gestion des erreurs
set -euo pipefail

# Définir l'IFS (Internal Field Separator) pour gérer correctement les espaces blancs
IFS=$'\n\t'

# Obtenir l'utilisateur courant
USER_TO_ADD=$(whoami)

# Vérifier si l'utilisateur est déjà dans le groupe sudo
if groups "$USER_TO_ADD" | grep -q "\bsudo\b"; then
    echo "$USER_TO_ADD est déjà dans le groupe sudo."
else
    echo "$USER_TO_ADD n'est pas dans le groupe sudo. Ajout en cours..."
    sudo ansible-playbook ~/add_user_to_sudo.yml -e "user_to_add=$USER_TO_ADD"
fi

# Ajouter le chemin où pipx installe les binaires au PATH
# export PATH="~/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Fonction pour afficher les messages de statut
status_message() {
    echo "[*] $1"
}  


# Vérification des fichiers nécessaires
if [[ ! -f inventory.ini ]]; then
    echo "[ERREUR] Le fichier inventory.ini est manquant. Veuillez le créer avant d'exécuter le script."
    exit 1
fi

if [[ ! -f main.yml ]]; then
    echo "[ERREUR] Le fichier main.yml est manquant. Veuillez le créer avant d'exécuter le script."
    exit 1
fi

# Vérification si Ansible est déjà installé
if ! command -v ansible &> /dev/null
then

    # Mise à jour des paquets du système et installation des outils de base
    status_message "Ansible n'est pas installé. Installation en cours..."
    
    status_message "Configuration du DNS pour utiliser le serveur DNS de Quad9"
    echo "nameserver 9.9.9.9" | sudo tee /etc/resolv.conf

    # Nettoyer le cache des paquets, mettre à jour la liste et les paquets
    # sudo rm -v /var/cache/apt/archives/lock
    sudo DEBIAN_FRONTEND=noninteractive apt clean
    sudo DEBIAN_FRONTEND=noninteractive apt update
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt autoremove -y

    sudo apt install pipx -y

    # Assurer que le chemin où pipx installe les binaires est ajouté au PATH
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
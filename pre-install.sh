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
    clear
    echo "$USER_TO_ADD est déjà dans le groupe sudo."

else
    echo "$USER_TO_ADD n'est pas dans le groupe sudo. Ajout en cours..."
    #ansible-playbook ~/add_user_to_sudo.yml -e "user_to_add=$USER_TO_ADD"

    usermod -aG sudo $USER_TO_ADD

    clear
    printf "%s \\n" "[Succès] Votre compte : ${USER_TO_ADD} est à présent membre du groupe sudo"
fi


status_message "Run : bash -x install.sh -> Ce script ne doit pas être exécuté en tant qu'utilisateur root."
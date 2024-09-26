#!/bin/bash

# Activer le mode strict de Bash pour une meilleure gestion des erreurs
set -euo pipefail

# Définir l'IFS (Internal Field Separator) pour gérer correctement les espaces blancs
IFS=$'\n\t'

# Fonction pour afficher les messages de statut jaune
status_message_system() {
    echo "\033[0;33m [*] $1 \033[0m"
}  

# Fonction pour afficher les messages d'erreur rouge
status_message_error() {
    echo "\033[0;31m [*] $1 \033[0m"
}

# Fonction pour afficher les messages de succés vert
status_message_succes() {
    echo "\033[0;32m [*] $1 \033[0m"
}


# Obtenir l'utilisateur courant
echo -e "[*] Veuillez entrer votre nom d'utilisateur pour la suite du script : " 
read USER_TO_ADD


# Vérifier si l'utilisateur est déjà dans le groupe sudo
if groups "$USER_TO_ADD" | grep -q "\bsudo\b"; then
    clear
    status_message_system "$USER_TO_ADD est déjà dans le groupe sudo."

else
    echo "$USER_TO_ADD n'est pas dans le groupe sudo. Ajout en cours..."
    #ansible-playbook ~/add_user_to_sudo.yml -e "user_to_add=$USER_TO_ADD"

    usermod -aG sudo $USER_TO_ADD

    clear
    status_message_succes "Votre compte : ${USER_TO_ADD} est à présent membre du groupe sudo"
fi


status_message_system "Run : bash -x install.sh"
status_message_error "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
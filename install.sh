#!/bin/bash

# Logo function
print_logo() {
cat << "EOF"
               __                                                  __
_____   __ ___/  |_  ____               _____   ____  __ __  _____/  |_  ___________
\__  \ |  |  \   __\/  _ \    ______   /     \ /  _ \|  |  \/    \   __\/ __ \_  __ \
 / __ \|  |  /|  | (  <_> )  /_____/  |  Y Y  (  <_> )  |  /   |  \  | \  ___/|  | \/
(____  /____/ |__|  \____/            |__|_|  /\____/|____/|___|  /__|  \___  >__|
     \/                                     \/                  \/          \/

/////////////////////////////////////////////////////////////////////////////////////

EOF
}

clear
print_logo

while true; do
  read -p "Have you already edited the auto-mounter.conf config file to fit your servers IP and mount points? (yes/no): " answer
  answer=${answer,,}

  if [[ "$answer" == "yes" ]]; then
    clear
    print_logo
    echo "Great to hear! The script will now install the script as service."
    printf "\n"

    echo "Creating folder /etc/auto-mounter/ for needed exec files"
    sudo mkdir -p /etc/auto-mounter/
    printf "\n"

    echo "Copying auto-mounter.sh to /etc/auto-mounter/"
    sudo cp ./auto-mounter.sh /etc/auto-mounter/
    sudo chmod 775 /etc/auto-mounter/auto-mounter.sh
    printf "\n"

    echo "Copying auto-mounter.conf to /etc/auto-mounter/"
    sudo cp ./auto-mounter.conf /etc/auto-mounter/
    sudo chmod 665 /etc/auto-mounter/auto-mounter.conf
    printf "\n"

    echo "Setting ownership for folder and files in /etc/auto-mounter/ "
    sudo chown root:root -R /etc/auto-mounter/
    printf "\n"

    echo "Ccopying mount-nfs-folders.service to /etc/systemd/system/"
    sudo cp ./auto-mounter.service /etc/systemd/system/
    printf "\n"

    echo "Ccopying mount-nfs-folders.timer to /etc/systemd/system/"
    sudo cp ./auto-mounter.timer /etc/systemd/system/
    printf "\n"

    echo "Reloading systemd daemon"
    sudo systemctl daemon-reload
    printf "\n"

    echo "Enabling service"
    sudo systemctl enable auto-mounter.service
    sudo systemctl start auto-mounter.service
    printf "\n"

    echo "Enabling service timer"
    sudo systemctl enable auto-mounter.timer
    sudo systemctl start auto-mounter.timer
    printf "\n"

    echo "--------------------------------------------------------------------------------"
    sudo systemctl status auto-mounter.service | head -n 7
    echo "--------------------------------------------------------------------------------"
    sudo systemctl status auto-mounter.timer

    break
  elif [[ "$answer" == "no" ]]; then
    clear
    print_logo
    echo "Please first go edit the config file, the script will run after installation and might create unwanted mountpoints. Thank you!"
    echo "Instructions of WHAT to edit are in the file itself. Enjoy."
    break
  else
    clear
    print_logo
    echo "This is not a valid answer. Please answer 'yes' or 'no'."
  fi
done

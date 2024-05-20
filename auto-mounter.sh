#!/bin/bash

#--------- EDIT HERE --------------------------------------------------------------#
#---------------------------- EDIT HERE -------------------------------------------#
#---------------------------------------------- EDIT HERE -------------------------#
#----------------------------------------------------------------- EDIT HERE ------#
# Chose your mount type NFS or SMB, if using SMB fill "SMB login information", if not, leave as is.
MOUNT_TYPE="SMB"

# Replace with IP or hostname of your remote ( source of backups )
server="192.168.99.99"

# SMB login information   Only fill if you going to use SMB mounting
username="your_login"
password="your_password"
domain=""  # Optional, only if your environment uses domain authentication

# Array of NFS prefixes and their corresponding folders, allowing multiple volumes to be mounted
declare -A nfs_mounts=(
    ["volume1"]="media/movies media/tvseries" # You can also mount folders inside of mountpoint (if allowed by NFS server)
    ["volume2"]="downloads"
)

# Mount point prefix - parent local folder, all mountpoints will be mounted inside.
local_mount_point_prefix="/synology"



#--- DO NOT EDIT BELOW ------------------------------------------------------------#
#---------------------- DO NOT EDIT BELOW -----------------------------------------#
#----------------------------------------- DO NOT EDIT BELOW ----------------------#
#----------------------------------------------------------- DO NOT EDIT BELOW ----#

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

clear && print_logo

# Check for sudo package
if ! dpkg -s "sudo" &> /dev/null; then
  echo "Sudo is not installed. Trying to install it."
  apt-get install sudo
  if ! sudo apt-get install sudo &> /dev/null; then
    echo "Failed to install sudo. Please install it manually and rerun the script."
    exit 1  # Exit script with error code
  fi
fi



if [ "$MOUNT_TYPE" == "NFS" ]; then
  # Check if nfs-common is installed silently
  if ! dpkg -s "nfs-common" &> /dev/null; then
    echo "Installing nfs-common..."
    sudo apt-get install nfs-common
  fi
elif [ "$MOUNT_TYPE" == "SMB" ]; then
  # Check if cifs-utils is installed silently
  if ! dpkg -s "cifs-utils" &> /dev/null; then
    echo "Installing cifs-utils..."
    sudo apt-get install cifs-utils
  fi
else
  echo "Invalid MOUNT_TYPE: $MOUNT_TYPE"
  exit 1
fi

clear && print_logo


# Loop through each NFS prefix in the array
for nfs_prefix in "${!nfs_mounts[@]}"; do
  # Get the folders corresponding to the current NFS prefix
  folders="${nfs_mounts[$nfs_prefix]}"

  # Loop through each folder
  for folder in $folders; do
    # Construct the mount point path
    local_mount_point="$local_mount_point_prefix/$folder"

    # Create the mount point directory if it doesn't exist
    if [ ! -d "$local_mount_point" ]; then
      sudo mkdir -p "$local_mount_point"
      echo "Created mount point directory: $local_mount_point"
    fi

    # Check if the folder is already mounted
    if mountpoint -q "$local_mount_point"; then
      echo "$folder is already mounted at $local_mount_point"
    else

      if [ "$MOUNT_TYPE" == "NFS" ]; then
        # Mount the folders using NFS
        sudo mount -t nfs -o rw,defaults ${server}:${nfs_prefix}/${folder} ${local_mount_point}
      elif [ "$MOUNT_TYPE" == "SMB" ]; then
        # Mount the folders using SMB
        sudo mount -t cifs -o ro,username=${username},password=${password}${domain:+,domain=$domain} //${server}/${folder} ${local_mount_point}
      else
        echo "Invalid MOUNT_TYPE: $MOUNT_TYPE"
        exit 1
      fi

      # Check the mount status (optional)
      if [ $? -eq 0 ]; then
        echo "Successfully mounted $folder to $local_mount_point"
      else
        echo "Failed to mount $folder"
      fi
    fi
  done
done

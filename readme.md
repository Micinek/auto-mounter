```            __                                                  __               
_____   __ ___/  |_  ____               _____   ____  __ __  _____/  |_  ___________ 
\__  \ |  |  \   __\/  _ \    ______   /     \ /  _ \|  |  \/    \   __\/ __ \_  __ \
 / __ \|  |  /|  | (  <_> )  /_____/  |  Y Y  (  <_> )  |  /   |  \  | \  ___/|  | \/
(____  /____/ |__|  \____/            |__|_|  /\____/|____/|___|  /__|  \___  >__|   
     \/                                     \/                  \/          \/       
```

Auto-Mounter is a simple bash script allowing you to mount specified folders via NFS or SMB.

Executed manualy or with systemd service and timer, it mounts all folders specified in the bash script and periodically checks if folders are mounted and remounts them.

Originaly created in conjunction with another script "mbackuper" as easy way to mount folders in backup event on my server without leaving them mounted all the time and open for exploit.

#

## Please first edit the auto-mounter.sh file according to your needs, every line you need to change is commented and explained, with examples.

#

### If you want to install the script as service, just run the  "install.sh".

The script will copy the shell script to /usr/local/bin and service files to /etc/systemd/system, then enables the service and timer. Print out status of services.


#
#

Made on Ubuntu 22.04 LTS. Script will check for SUDO, and install it if missing, also based on your choice of mount method, it will attempt to install tools to be able to mount ( nfs-common or cifs-utils ).

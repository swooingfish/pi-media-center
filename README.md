# Raspbery Pi media center setup

This will install a OSMC media center on your raspberry pi. The current distro of OSMC is running debian jessie.

## OSMC installation

With formatted SD card download osmc install or image and write to the SD card 
https://osmc.tv/download/

Follow instructions

## Login to the Raspberry pi once it's booted.

      ssh osmc@[ip-address]
      password: osmc

## Install dependencies

      sudo apt-get -y install git python-gdbm python-cheetah python-openssl par2 samba unrar

## Setup Samba file server

Samba is a network file server so you can access the media files on your network though differnet devices. 

      sudo nano /etc/samba/smbd.conf
      
Around line number 193 (press CRTL + C) to check the current line number, change “read only” to from yes to no.

      [homes]
      comment = Home Directories
      browseable = no  
      # By default, the home directories are exported read-only. Change the
      # next parameter to 'no' if you want to be able to write to them.
      read only = no
 
Restart the samba service
 
      sudo service smbd start

Add a samba user called "osmc".

      sudo smbpasswd -a osmc
      
You should now be able to access the fileserver via smb://osmc on a mac or start and run \\osmc on a PC.

## Setup MySQL Server

Install the mysql server

	sudo apt-get install mysql-server
	
When the installation pormps for a root password it's always a good idea to set one

Once the mysql server is installed connect using the mysql command and the root user and any password you might have set on installation.

	mysql -u root -p

Create mysql user, changing db_user and db_password to what ever you want to have.

	CREATE USER 'db_user'@'%' IDENTIFIED BY 'db_password';
	GRANT ALL PRIVILEGES ON *.* TO 'db_user'@'%';
	FLUSH PRIVILEGES;


## Configure OSMC to use the MySQL Server to save your library data

This will allow us to share the current watched progress of your library accorss the network to other OSMC devices e.g. if they are in differnet locations. It will also allow us to eaisally backup the database with automysqlbackup

      nano ~/.kodi/userdata/advancedsettings.xml
       
Add in the following settings, changing your username and password to what you have set when setting up the mysql server and database user.

	<advancedsettings>
	  <loglevel hide="true">-1</loglevel> <!-- Disables logging -->
	  <nodvdrom>true</nodvdrom>
	  
	  <videodatabase>
		<type>mysql</type>
		<host>localhost</host>
		<port>3306</port>
		<user>db_user</user>
		<pass>db_password</pass>
	  </videodatabase> 
	  <musicdatabase>
		<type>mysql</type>
		<host>localhost</host>
		<port>3306</port>
		<user>db_user</user>
		<pass>db_password</pass>
	  </musicdatabase>
	  <videolibrary>
		<importwatchedstate>true</importwatchedstate>
		<importresumepoint>true</importresumepoint>
	  </videolibrary>
	  
	  <network>
		 <buffermode>1</buffermode> <!-- Default is 1 -->
		 <cachemembuffersize>52428800</cachemembuffersize> <!-- Default is 20971520 bytes or 20 MB -->
		 <readbufferfactor>2.0</readbufferfactor> <!-- Default is 1.0 -->
	  </network>

	</advancedsettings>



## NZB installation

      sudo addgroup nzb
      sudo useradd --system --user-group --no-create-home --groups nzb sabnzbd

      wget http://downloads.sourceforge.net/project/sabnzbdplus/sabnzbdplus/0.7.20/SABnzbd-0.7.20-src.tar.gz
      tar xzf SABnzbd-0.7.20-src.tar.gz
      sudo mv SABnzbd-0.7.20 /usr/local/sabnzbd
      sudo chown -R sabnzbd:nzb /usr/local/sabnzbd

      sudo mkdir /var/sabnzbd
      sudo chown sabnzbd:nzb /var/sabnzbd

      sudo su sabnzbd -c "/usr/local/sabnzbd/SABnzbd.py -f /var/sabnzbd -s [IP ADDRESS]:8080"

If it's all working, you should be able to navigate to [IP ADDRESS]:8080 and see the web interface
Ctrl+C to kill it

## Sickbeard installation

      sudo useradd --system --user-group --no-create-home sickbeard

      git clone git://github.com/midgetspy/Sick-Beard.git
      sudo mv Sick-Beard /usr/local/sickbeard
      sudo chown -R sickbeard:nzb /usr/local/sickbeard
      sudo chmod ug+rw /usr/local/sickbeard/autoProcessTV/
      sudo mkdir /var/sickbeard
      sudo chown sickbeard:nzb /var/sickbeard

      sudo su sickbeard -c "/usr/local/sickbeard/SickBeard.py --datadir /var/sickbeard --config /var/sickbeard/sickbeard.ini"

Test it out at [IP ADDRESS]:8081 and Ctrl+C when you're done

## Couchpotato installation

      sudo useradd --system --user-group --no-create-home couchpotato

      git clone git://github.com/RuudBurger/CouchPotatoServer.git
      sudo mv CouchPotatoServer /usr/local/couchpotato
      sudo chown -R couchpotato:couchpotato /usr/local/couchpotato
      sudo mkdir /var/couchpotato
      sudo chown -R couchpotato:couchpotato /var/couchpotato

      sudo su couchpotato -c "/usr/local/couchpotato/CouchPotato.py --data_dir=/var/couchpotato --config_file=/var/couchpotato/couchpotato.ini"

Test it out at [IP ADDRESS]:5050 and Ctrl+C when you're done


## Deluge 

Instrucitons for setting up Deluge
Source : http://www.howtogeek.com/142044/how-to-turn-a-raspberry-pi-into-an-always-on-bittorrent-box/

Setting up Deluge for ThinClient Access. 

	sudo apt-get install deluged
	
	sudo apt-get install deluge-console
	
This will download the Deluge daemon and console installation packages and run them. When prompted to continue, type Y. After Deluge has finished installing, we need to run the Deluge daemon. Enter the following commands:

	deluged
	
	sudo pkill deluged

This starts the Deluge daemon (which creates a configuration file) and then shuts down the daemon. We’re going to edit that configuration file and then start it back up. Type in the following commands to first make a backup of the original configuration file and then open it for editing:

	cp ~/.config/deluge/auth ~/.config/deluge/auth.old
	nano ~/.config/deluge/auth

Once inside nano, you’ll need to add a line to the bottom of the configuration file with the following convention:

	user:password:level
	
Where in user is the username you want for Deluge, password is the password you want, and the level is 10 (the full-access/administrative level for the daemon). For our purposes, we used pi:raspberry:10.When you’re done editing, hit CTRL+X and save your changes. Once you’ve saved them, start up the daemon again and then the console:

	deluged
	
	deluge-console

If starting the console gives you an error code instead of nice cleanly formatted console interface type “exit” and then make sure you’ve started up the daemon.

Once you’re inside the console, we need to make a quick configuration change. Enter the following:

	config -s allow_remote True
	
	config allow_remote
	
	exit

This enables remote connections to your Deluge daemon and double checks that the config variable has been set. Now it’s time to kill the daemon and restart it one more time so that the config changes take effect:

	sudo pkill deluged
	
	deluged

At this point your deluge daemon is ready for remote access. We need to install the Deluge desktop client in order to finish the configuration. Hit up the Deluge Downloads page http://dev.deluge-torrent.org/wiki/Download and select the installer for your operating system. Once you have installed the Deluge desktop client, run it for the first time; we need to make some quick changes.

Once launched, navigate to Preferences -> Interface. Within the interface submenu, you’ll see a check box for “Classic Mode”. By default it is checked. Uncheck it.

Click OK and then restart the Deluge desktop client. This time when Deluge starts, it will present you with the Connection Manager. Here is where you input the information about your Raspberry Pi and the Deluge installation. Click the Add button in the Connection Manger and plug in your Pi’s info like so:

You’ll need to input the IP address of the Raspberry Pi on your network, as well as the username and password you set during the earlier configuration. Leave the port at the default 58846. Click Add.

Back in the Connection Manager, you’ll see the entry for the Raspberry Pi; if all goes well, the indicator light will turn green like so:

Click Connect and you’ll be kicked into the interface, connected to the remote machine:


It’s a fresh install, nary a .torrent in site, but our connection between the remote machine and the desktop client is a success!

Go ahead and configure the WebUI now (if you wish to do so), or skip down to the proxy setup portion of the tutorial.

### Setting up Deluge for WebUI Access

Configuring the WebUI is significantly faster but, as we mentioned before, you’ll have access to less features than with the full ThinClient experience. One of the most useful features you gain from using the ThinClient, associating .torrent files with the Deluge ThinClient for automatic transfer to the remote Deluge daemon, is missing from the WebUI experience.

To install the WebUI, go to the terminal on your Pi and enter the following commands. Note: If you already installed the Deluge daemon in the ThinClient section of the tutorial, skip the first command here.


	sudo apt-get install deluged
	
	sudo apt-get install python-mako
	
	sudo apt-get install deluge-web
	
	deluge-web
	
This sequence installs the Deluge daemon (if you didn’t already install it in the last section), Mako (a template gallery for Python that the WebUI needs), the WebUI itself, and then starts the WebUI program.

The default port for the WebUI is 8112; if you wish to change it use the following commands:

	sudo pkill deluge-web
	
	nano ~/.config/deluge/web.conf

This stops the WebUI and opens up the configuration file for it. Use nano to edit the line: “port”: 8112, and replace the 8112 with any port number (above 1000, as 1-1000 are reserved by the system).

Once you have the WebUI up and running, it’s time to connect into it using a web browser. You can use a browser on the Pi if you ever need to, but it’s not the most pleasant user experience and best left for emergencies. Open up a browser on your regular desktop machine and point it at the IP address of your Pi (e.g. http://192.168.1.102:8112).

You’ll be greeted with a password prompt (the default password is “deluge) and be immediately encouraged to change it after you enter it for the first time. After that, you’ll be able to interact with Deluge via the lightweight interface:


It’s not quite the same as the ThinClient, but it’s robust enough for light use and has the added benefit of serving as the point of connection for lots of torrent-control mobile apps.

## Autostarts

(You'll find the contents of each autostart script in the /startups folder)

### Sabnzbd

    sudo nano /etc/init.d/sabnzbd

Copy the contents from sabnzbd and save the changes

      sudo chmod 755 /etc/init.d/sabnzbd
      sudo update-rc.d sabnzbd defaults

      sudo /etc/init.d/sabnzbd start

Sabnbzd will now be running, and should automatically boot on startup.

### Sickbeard

      sudo nano /etc/init.d/sickbeard

Use the contents of sickbeard

      sudo chmod 755 /etc/init.d/sickbeard
      sudo update-rc.d sickbeard defaults

      sudo /etc/init.d/sickbeard start

### Couchpotato

      sudo nano /etc/init.d/couchpotato

Use the contents of couchpotato

      sudo chmod 755 /etc/init.d/couchpotato
      sudo update-rc.d couchpotato defaults

      sudo /etc/init.d/couchpotato start

### Deluge

	sudo nano /etc/default/deluge-daemon
	
Use the contents of deluge-daemon.conf

	sudo chmod 755 /etc/default/deluge-daemon
	

	sudo nano /etc/init.d/deluge-daemon

Use the contents of deluge-daemon.sh
     
	sudo chmod 755 /etc/init.d/deluge-daemon
	sudo update-rc.d deluge-daemon defaults

## Storage

(This assumes that you'll be storing the files to an external USB harddrive, plugged into the Pi's USB)

We're going to mount the drive to /var/multimedia

      sudo mkdir -p /var/multimedia/
      sudo mount -t vfat -o uid=pi,gid=pi /dev/sda1 /var/multimedia/

Automount the drive to that location

      /dev/sda1 /var/multimedia vfat users,umask=1000,rw,auto 0 0

Create the necessary folders for downloaded files

      sudo mkdir -p /var/multimedia/films
      sudo mkdir -p /var/multimedia/tv
      sudo mkdir -p /var/multimedia/incoming/sabnzbd/incomplete
      sudo mkdir -p /var/multimedia/incoming/sabnzbd/complete
      sudo mkdir -p /var/multimedia/incoming/sabnzbd/complete_tv 
      sudo mkdir -p /var/multimedia/incoming/sabnzbd/complete_films
      sudo mkdir -p /var/multimedia/incoming/sickbeard
      sudo mkdir -p /var/multimedia/incoming/couchpotato

By default, this folder won't be visible on the network, so symlink it so that it's mountable as a network drive

      cd /home/pi

      ln -s /var/multimedia multimedia

When you browse to your Pi on the network, you'll now have access to downloaded files

## Program configuration and settings

### Sabnzbd (IP:8080)

* General/Host = 0.0.0.0
* Folders/Temporary Download Folder = /var/multimedia/incoming/sabnzbd/incomplete
* Folders/Completed Download Folder = /var/multimedia/incoming/sabnzbd/complete
* Post-Processing Scripts Folder = /usr/local/sickbeard/autoProcessTV
* Servers = add your NNTP server(s)
* Index Sites = add your index server(s)
* Categories = add as follows:
  films, default, default, default, /var/multimedia/incoming/sabnzbd/complete_films
  tv, default, default, sabToSickBeard.py, /var/multimedia/incoming/sabnzbd/complete_tv

### Sickbeard (IP:8081)

* General/Misc/Launch Browser = off
* Search Settings/NZB Search/Method = SABnzbd
* Search Settings/NZB Search/Host = http://localhost:8080
* Search Settings/NZB Search/API Key = Your SABnzbd api key, from the general config page
* Search Settings/NZB Search/Category = tv
* Search Providers = add your index server(s)
* Post Processing/Keep Original Files = off

### Couchpotato (IP:5050G)

* SABnzbd = enabled
* SABnzbd/api key = Your SABnzbd api key, from the general config page
* SABnzbd/category = films
* Add your index server(s)
* Rename = yes
* Rename/From = /var/multimedia/incoming/sabnzbd/complete_films/
* Rename/To = /var/multimedia/films
* Rename/Cleanup = yes



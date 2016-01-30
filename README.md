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

http://www.howtogeek.com/142044/how-to-turn-a-raspberry-pi-into-an-always-on-bittorrent-box/


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



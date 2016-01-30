# Raspbery Pi media center setup

## RaspBMC installation

With formatted SD card in Mac


      curl -O http://svn.stmlabs.com/svn/raspbmc/release/installers/python/install.py
      chmod +x install.py


      sudo python install.py

Follow instructions

## Initial setup

ssh pi@[ip-address]
password: raspberry

      sudo apt-get -y install git

      sudo apt-get -y install python-gdbm python-cheetah python-openssl par2

      sudo sh -c "echo \"deb-src http://mirrordirector.raspbian.org/raspbian/ wheezy main contrib non-free rpi\" >> /etc/apt/sources.list"
      sudo apt-get update
      sudo apt-get -y build-dep unrar-nonfree
      sudo apt-get source -b unrar-nonfree
      sudo dpkg -i unrar*.deb

## NZB installation

      sudo addgroup nzb
      sudo useradd --system --user-group --no-create-home --groups nzb sabnzbd

      wget http://downloads.sourceforge.net/project/sabnzbdplus/sabnzbdplus/0.7.3/SABnzbd-0.7.3-src.tar.gz
      tar xzf SABnzbd-0.7.3-src.tar.gz
      sudo mv SABnzbd-0.7.3 /usr/local/sabnzbd
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



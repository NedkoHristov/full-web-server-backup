# Web Server Backup Script

This is a bash script for backing up multiple web sites, MySQL databases and /etc/ into a specified backups directory.

Once configured (variables set within the script), it does this:

* Creates a directory for your site (file) backups (if it doesn't exist) with option for exclude;
* Creates a directory for your MySQL dumps (if it doesn't exist);
* Loops through all of your MySQL databases and dumps each one of them to a gzipped file;
* Creates a directory for your configurations (/etc/) (if it doesn't exist);
* Tars and gzips each folder within your sites directory (I keep my websites in /var/www/html/).

# BETA WARNING

___This script works fine for me (using  Ubuntu 16.04.3 LTS on Vultr and selfhosted), but servers vary greatly. USE THIS SCRIPT AT YOUR OWN RISK! There is always risk involved with running a script. I AM NOT RESPONSIBLE FOR DAMAGE CAUSED BY THIS SCRIPT.
For this reason I removed the delete functionality from the project I forked. ___

You may very well know more about bash scripting and archiving than I do. If you find any flaws with this script or have any recommendations as to how this script can be improved, please fork it and send me a pull request.

# Installation

* __MOST IMPORTANTLY:__ Open the backup.sh file in a text editor and set the configuration variables at the top (see below).
* Optionally, edit the tar command on line 97 to add some more --exclude options (e.g. --exclude="cache/*")
* Place the backup.sh file somewhere on your server (something like /opt/full-web-server-backup).
* Make sure the backup.sh script is executable by root: `sudo chmod 744 /opt/full-web-server-backup/backup.sh`
* Preferably set up cron to run it every night (see below).

# Configuration

There are a bunch of variables that you can set to customize the way the script works. _Some of them __must__ be set before running the script!_

NOTE: The BACKUP\_DIR setting is preset to /backups/site-backups. If you want to use something like /var/site-backups, you'll need to create the directory first and set it to be writable by you.

## General Settings:

* __BACKUP\_DIR__: The parent directory in which the backups will be placed. It's preset to: `"/backups/site-backups"`
* __KEEP\_MYSQL__: How many days worth of mysql dumps to keep. It's preset to: `"14"`
* __KEEP\_SITES__: How many days worth of site tarballs to keep. It's preset to: `"2"`

## MySQL Settings:

* __MYSQL\_HOST__: The MySQL hostname. It's preset to the standard: `"localhost"`
* __MYSQL\_USER__: The MySQL username. It's preset to the standard: `"root"`
* __MYSQL\_PASS__: The MySQL password. ___You'll need to set this yourself!___
* __MYSQL\_BACKUP\_DIR__: The directory in which the dumps will be placed. It's preset to: `"$BACKUP\_DIR/mysql/"`

## Web Site Settings:

* __SITES\_DIR__: This is the directory where you keep all of your web sites. It's preset to: `"/var/www/html/"`
* __SITES\_BACKUP\_DIR__: The directory in which the archived site files will be placed. It's preset to: `"$BACKUP_DIR/sites/"`

## Date format: (change if you want)

* __THE\_DATE__: The date that will be appended to filenames. It's preset to: `"$(date '+%Y-%m-%d')"` (2017-11-07)

## Paths to commands: (probably won't need to change these)

* __MYSQL\_PATH__: Path to mysql. It's preset to: `"$(which mysql)"`
* __MYSQLDUMP\_PATH__: Path to mysqldump. It's preset to: `"$(which mysqldump)"`
* __FIND\_PATH__: Path to find. It's preset to: `"$(which find)"`
* __TAR\_PATH__: Path to tar. It's preset to: `"$(which tar)"`
* __RSYNC\_PATH__: Path to rsync. It's preset to: `"$(which rsync)"`

# Running with cron (recommended)

Once you've tested the script, I recommend setting it up to be run every night with cron. Here's a sample cron config:

    SHELL=/bin/bash
    PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
    MAILTO=jason@example.com
    HOME=/root

    30 4 * * * root /opt/full-web-server-backup/backup.sh
    
That'll run the script (located in /usr/local) at 4:30 every morning and email the output to jason@example.com.

If you want to only receive emails about errors, you can use:

    30 4 * * * root /usr/local/web-server-backup/backup.sh > /dev/null

So, take the above example, change the email address, etc., save it to a text file, and place it in `/etc/cron.d/`. That should do it.

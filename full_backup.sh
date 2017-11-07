#!/bin/bash

# BEGIN CONFIGURATION ==========================================================

BACKUP_DIR="/var/www/backup/full_backup/$THE_DATE"  # The directory in which you want backups placed
DUMP_MYSQL=true
TAR_SITES=true
ETC_BACKUP=true

MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASS="YOUR_MYSQL_ROOT_PASSWORD"
MYSQL_BACKUP_DIR="$BACKUP_DIR/$THE_DATE-mysql/"

SITES_DIR="/var/www/html/"
SITES_BACKUP_DIR="$BACKUP_DIR/$THE_DATE-sites/"
ETC_DIR="/etc/"
ETC_BACKUP_DIR="$BACKUP_DIR/$THE_DATE-etc/"

# You probably won't have to change these
THE_DATE="$(date '+%Y-%m-%d')"

MYSQL_PATH="$(which mysql)"
MYSQLDUMP_PATH="$(which mysqldump)"
FIND_PATH="$(which find)"
TAR_PATH="$(which tar)"

# END CONFIGURATION ============================================================

# Announce the backup time
echo "Backup Started: $(date)"

# Create the backup dirs if they don't exist
if [[ ! -d $BACKUP_DIR ]] || [[ $ETC_BACKUP=true ]]
  then
  mkdir -p "$BACKUP_DIR"
fi
if [[ ! -d $MYSQL_BACKUP_DIR ]]
  then
  mkdir -p "$MYSQL_BACKUP_DIR"
fi
if [[ ! -d $SITES_BACKUP_DIR ]]
  then
  mkdir -p "$SITES_BACKUP_DIR"
fi

if [[ ! -d $ETC_BACKUP_DIR ]]
  then
  mkdir -p "$ETC_BACKUP_DIR"
fi


if [ "$DUMP_MYSQL" = "true" ]
  then

  # Get a list of mysql databases and dump them one by one
  echo "------------------------------------"
  DBS="$($MYSQL_PATH -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS -Bse 'show databases')"
  for db in $DBS
  do
    if [[ $db != "information_schema" && $db != "mysql" && $db != "performance_schema" ]]
      then
      echo "Dumping: $db..."
      $MYSQLDUMP_PATH --opt --skip-add-locks -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $db | gzip > $MYSQL_BACKUP_DIR$db\_$THE_DATE.sql.gz
    fi
  done

fi

if [ "$TAR_SITES" == "true" ]
  then

  # Get a list of files in the sites directory and tar them one by one
  echo "------------------------------------"
  cd $SITES_DIR
  for d in *
  do
    echo "Archiving $d..."
    $TAR_PATH --exclude="*/log" -C $SITES_DIR -czf $SITES_BACKUP_DIR/$d\_$THE_DATE.tgz $d
###    $TAR_PATH -C $ETC_DIR -czf $SITES_BACKUP_DIR/$d\_$THE_DATE.tgz $d
done
fi
  echo "------------------------------------"


if [ "$ETC_BACKUP" == "true" ]
  then

  # Get a list of files in the sites directory and tar them one by one
  echo "------------------------------------"
  cd $ETC_DIR
    echo "Archiving $ETC_DIR"
    $TAR_PATH -cpzf $ETC_BACKUP_DIR/$THE_DATE.tgz /etc/
fi

# Announce the completion time
echo "------------------------------------"
echo "Backup Completed: $(date)"

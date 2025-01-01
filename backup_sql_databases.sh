#!/bin/bash
# MySQL/MariaDB Database Backup Script
# Purpose: Automatically backs up all MySQL/MariaDB databases, separating structure and data
# Creates compressed backups with timestamps and manages backup retention
# Original script: https://github.com/BarcaLS/backup_sql_databases
# Requirements: MySQL/MariaDB client, gzip

# Database Connection Configuration
###########################################################################################
SQL_HOST="127.0.0.1"      # Database server host
SQL_USER="XXXXXXXXXXXX" # Database user with backup privileges
SQL_PASS="XXXXXXXXXXXX" # Database password
SQL_PORT=3306             # Database server port

# Backup Directory Configuration
###########################################################################################
MYSQL_DIR="/volume1/@appstore/MariaDB10/usr/local/mariadb10/bin/" # MySQL/MariaDB binaries location Synology DSM 7.2.2-72806 Update 2 
BACKUP_DIR_STRUCTURE="/volume1/backup/mysql/backup_files/"         # Directory for database structure backups
BACKUP_DIR_DATA="/volume1/backup/mysql/backup_files/"             # Directory for database data backups

# Backup Retention and Timestamp Configuration
###########################################################################################
DAYS_KEEP=60  # Number of days to retain backups before automatic deletion
DATESTAMP=$(date +%Y_%m_%d_%H_%M_%S)  # Full timestamp for backup files
DATE=$(date +%d_%m_%Y)                 # Date for backup directory structure

# Directory Creation and Validation
###########################################################################################
# Create backup directories if they don't exist
if ! mkdir -p "${BACKUP_DIR_DATA}"; then
    echo "Error: Failed to create backup data directory"
    exit 1
fi

if ! mkdir -p "${BACKUP_DIR_STRUCTURE}"; then
    echo "Error: Failed to create backup structure directory" 
    exit 1
fi

# Backup Cleanup
###########################################################################################
# Remove backups older than DAYS_KEEP
# -mtime +$DAYS_KEEP finds files modified more than DAYS_KEEP days ago
find ${BACKUP_DIR_DATA}* -mtime +$DAYS_KEEP -exec rm -f {} \; 2> /dev/null
find ${BACKUP_DIR_STRUCTURE}* -mtime +$DAYS_KEEP -exec rm -f {} \; 2> /dev/null

# MySQL Client Validation
###########################################################################################
# Check if MySQL client exists in specified directory
if ! command -v "${MYSQL_DIR}/mysql" &> /dev/null; then
    echo "Error: MySQL client not found at ${MYSQL_DIR}/mysql"
    exit 1
fi

# Database Backup Process
###########################################################################################
# Iterate through all databases and create backups
for db in $("${MYSQL_DIR}/mysql" --host="$SQL_HOST" --port="$SQL_PORT" --user="$SQL_USER" --password="$SQL_PASS" -e "SHOW DATABASES;" 2>/dev/null | tr -d "| " | grep -v Database); do
    # Skip system databases and databases starting with underscore
    if [[ "$db" != _* ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "information_schema" ]]; then
        # Generate backup filenames with timestamp
        FILENAME_STRUCTURE="${BACKUP_DIR_STRUCTURE}/${db}/${DATE}/${db}-${DATESTAMP}_structure.sql.gz"
        FILENAME_DATA="${BACKUP_DIR_DATA}/${db}/${DATE}/${db}-${DATESTAMP}_data.sql.gz"
        
        # Create backup directory structure
        mkdir -p "$(dirname "$FILENAME_STRUCTURE")"
        mkdir -p "$(dirname "$FILENAME_DATA")"
        
        # Backup database structure (schema only)
        # --no-data: Skip table data
        # --opt: Optimal backup options
        # --routines: Include stored procedures and functions
        if ! "${MYSQL_DIR}/mysqldump" --no-data --host="$SQL_HOST" --port="$SQL_PORT" --user="$SQL_USER" --password="$SQL_PASS" --opt --verbose --routines --force --databases "$db" 2>/dev/null | gzip > "$FILENAME_STRUCTURE"; then
            echo "Error: Failed to backup structure for database $db"
            continue
        fi
        
        # Backup database data (content only)
        # --no-create-info: Skip table creation
        if ! "${MYSQL_DIR}/mysqldump" --no-create-info --host="$SQL_HOST" --port="$SQL_PORT" --user="$SQL_USER" --password="$SQL_PASS" --opt --verbose --routines --force --databases "$db" 2>/dev/null | gzip > "$FILENAME_DATA"; then
            echo "Error: Failed to backup data for database $db"
            continue
        fi
    fi
done
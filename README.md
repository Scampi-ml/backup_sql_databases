### Features

Script dumps all MySQL (or MariaDB) databases to separate SQL files (compressed to .sql.gz) named with timestamp.
It also removes old backups (older than specified amount of days).


Script updated for MariaDB 10 on Synology DSM 7.2.2-72806 Update 2 


- Added separation between data and structure
- Added each DB into its own folder
- Changed YmdHMS for filenames
- Added error reporting" or feedback on errors
- Added a bit of AI magic
- Added BACKUP_DIR_STRUCTURE path
- Added BACKUP_DIR_DATA path
- Added DATE for folders
- Added folder creation
- Added SQL_HOST var
- Added SQL_USER var


**NOTE:** use lowercase names in the path

**NOTE:** Do not change the path for MySQL: this is set for Synology MariaDB 10 - 10.11.6-1369


### Using the Task Scheduler in DSM

1.  Go to Control Panel / Task Scheduler / Create / Scheduled Task / User-defined script
2. Once you click on User-defined script a new window will open
3. General: In the Task field type in "MySQL Backup"
4. Check the "Enabled" option. Select root User
5. Schedule: Select Run on the following date "Daily"
6. Then select Start Time "00" : "00"
7. Repeat "Every hour" or whatever you want
8. Select Last Run Time to "23:00"
7. Task Settings: Check “Send run details by email“, add your email then copy paste the code below in the Run command area.

`/bin/bash /volume1/backup/mysql/backup.sh`

Info: https://kb.synology.com/en-global/DSM/tutorial/common_mistake_in_task_scheduler_script


8. After that click OK.
9. Run the script to be sure it works


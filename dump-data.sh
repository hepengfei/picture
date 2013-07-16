
db=$1
table=$2

mysqldump --add-locks=FALSE --add-drop-table=FALSE --lock-tables=FALSE -uroot  $db $table | sed 's/CREATE TABLE /CREATE TABLE IF NOT EXISTS /' | sed 's/INSERT INTO /INSERT IGNORE INTO /' 

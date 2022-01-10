#!/bin/sh
####
#### Neoclova MariaDB install
####

BASEDIR="/DATA/maria/base"
DATADIR="/DATA/maria/data"
LOGDIR="/DATA/maria/log"
TMPDIR="/DATA/maria/tmp"

#### User Add : maria
# groupadd dba
# useradd -g dba --system maria
useradd maria

echo "
PATH=\$PATH:${BASEDIR}/bin

export PATH
" >> /home/maria/.bash_profile

#### Make Directory : basedir, datadir, log
mkdir -p ${BASEDIR}
mkdir -p ${DATADIR} ${TMPDIR}
cd ${LOGDIR}
mkdir -p binary relay redo undo
chown -R maria.maria ${BASEDIR}
chown -R maria.maria ${DATADIR}
chown -R maria.maria ${LOGDIR}
chown -R maria.maria ${TMPDIR}


#### symbolic link : my.cnf
# ln -s ${BASEDIR}/my.cnf /etc/my.cnf
# ln -s ${BASEDIR} /usr/local/mysql

#### Linux Parameter : limits.conf, swappiness
echo "
#### MariaDB
maria   soft    nofile  65535
maria   hard    nofile  65535
maria   soft    core    unlimited
maria   hard    core    unlimited
" >> /etc/security/limits.conf

# echo "vm.swappiness = 1" >> /etc/sysctl.conf
# sysctl -w vm.swappiness=1

##### systemd
echo "
#### MariaDB
maria   ALL=NOPASSWD:   /bin/systemctl restart mariadb, /bin/systemctl stop mariadb, /bin/systemctl start mariadb, /bin/systemctl status mariadb
" >> /etc/sudoers

echo "[Unit]
Description=mariadb
After=network.target

[Service]
Type=forking
User=maria
Group=maria
LimitNOFILE=infinity
TasksMax=infinity
ExecStart=${BASEDIR}/support-files/mysql.server start
ExecStop=${BASEDIR}/support-files/mysql.server stop

[Install]
WantedBy=multi-user.target
" > /usr/lib/systemd/system/mariadb.service

systemctl daemon-reload

#echo "Change ${BASEDIR}/support-files/mysql.server : DATADIR, BASEDIR"
sed -i "s/^datadir=/datadir=${DATADIR}/" ${BASEDIR}/support-files/mysql.server
sed -i "s/^basedir=/basedir=${BASEDIR}/" ${BASEDIR}/support-files/mysql.server

#### MariaDB Installation
echo "${BASEDIR}/scripts/mariadb-install-db --defaults-file=${BASEIDR}/my.cnf --datadir=${DATADIR} --user=maria"

#### MariaDB Secure Installation
echo "su - maria; sudo systemctl start mariadb; ps -ef|grep maria
${BASEIDR}/bin/mariadb-secure-installation --basedir=${BASEDIR}"


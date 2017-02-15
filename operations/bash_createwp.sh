#!/bin/bash

# wordpress latest auto-install script, by alienation 24 jan 2013. run as root.
# usage: ~/wp-install alien /hsphere/local/home/alien/nettrip.org alien_wpdbname alien_wpdbusername p@sSw0rd
# ( wp-install shell-user folder db-name db-user-name db-user-pw )

#curl -X POST -v -u viridiantechnologies:viridsomtech -H "Content-Type: application/json"   https://api.bitbucket.org/2.0/repositories/viridiantech/"$ID" -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'

#local website
# download wordpress to temporary area

cd /tmp
rm -rf tmpwp
mkdir tmpwp
cd tmpwp
wget http://wordpress.org/latest.tar.gz
tar -xvzpf latest.tar.gz

# copy wordpress to where it will live, and go there, removing index placeholder if there is one
mv wordpress/* $2
cd $2
rm index.html

# create config from sample, replacing salt example lines with a real salt from online generator
grep -A 1 -B 50 'since 2.6.0' wp-config-sample.php > wp-config.php
wget -O - https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
grep -A 50 -B 3 'Table prefix' wp-config-sample.php >> wp-config.php

# put the appropriate db info in place of placeholders in our new config file
replace 'database_name_here' $3 -- wp-config.php
replace 'username_here' $4 -- wp-config.php
replace 'password_here' $5 -- wp-config.php

# change file ownership and permissions according to ideal at http://codex.wordpress.org/Hardening_WordPress#File_Permissions
touch .htaccess
chown $1:httpd .htaccess
chown -R $1:httpd *
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod -R 770 wp-content
chmod -R g-w wp-admin wp-includes wp-content/plugins
chmod g+w .htaccess

# thats it!
echo ALL DONE

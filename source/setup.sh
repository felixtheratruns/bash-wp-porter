#    This file is part of the bash version of "Porter".
#
#    Porter is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Porter is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Website Porter.  If not, see <http://www.gnu.org/licenses/>.

#example with variable names:
#doActions  site_vars_array=("${!1}") "$action_arguments" "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path"

#doActions "${var_arr[@]}" "$action_arguments" "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path" "$run_status"
doSetup(){
    local action_arguments=$1
    local script_dir=$2
    local sites_directory=$3 
    local base_vars_path=$4 
    local site_vars_array=("${!5}")  
    local current_site=$6
    local run_status=$7
    local local_dump_path="$script_dir/$sites_directory/$current_site"
    local local_uploads_path="$local_dump_path/uploads"
    mkdir -p "$local_uploads_path"

    #sourceVars "$base_vars_path"


    setActionOpts(){
        options=$1
        locations=$2
        echo "options: $options"
        echo "locations: $locations"
    }
    
    setActionOpts $action_arguments
    
    IFS=',' read -a options_array <<< $options
    IFS=',' read -a location_array <<< $locations
    
    for i in "${site_vars_array[@]}" 
    do 
      test_encrypt "$i"
    done 
    
    if [[ -z $options ]]; then
      printf "YOU HAVE SPECIFIED NO OPTIONS\n\n"
      abort 1;
    fi
    
    if [[ -z $locations ]]; then
      printf "YOU HAVE SPECIFIED NO LOCATIONS\n\n"
      abort 1;
    fi
    
    if [[ "$run_status" == 1 ]]; then
      printf "RUNNING, CURRENT SITE: $current_site\n\n"
    else
      printf "TESTING, CURRENT SITE: $current_site\n\n"
    fi

    getSetupSrc "$src"
    getSetupDest "$dest"

    compare_db_name="compare_$DB_NAME"
    sei="--skip-extended-insert"
    no_create_tables="--skip-add-drop-table --skip-extended-insert --no-create-info --insert-ignore" 
    no_data="--skip-add-drop-table --skip-extended-insert --insert-ignore --no-data" 

    if [[ -z "$WP_PREFIX" ]]; then
      WP_PREFIX='wp_'
    fi  
   

#       1 'db' create database (install wordpress? no)
#       2 'git' create git repo at location
#       3 'git_main' create main git repo
#       4 'ht' make .htaccess
#       5 'robots' robots.txt
#       6 'config' wp-config.php
#       7 'wp' wordpress files
#       8 'files' all files 4-7
#       9 'all' except git_main
#       10 'new' all and git_main 

    if $(isInOpts "options_array[@]" 'new'); then
        printf "new is in opts \n\n"
        makeGitMain "$git_name" 
    fi

    for location in ${location_array[@]}; do 


#            src_db_user=$dev_db_user
#            src_password=$dev_password
#
#            src_ssh_args=$dev_ssh_args
#            src_branch="$BRANCH"
#            src_comparedb="$DB_USER:$DB_PASSWORD@localhost"
#            src_url=$URL
#            src_mysql_args_nh=$dev_mysql_args_nh
#            src_db=$dev_db
#            src_path=$dev_path
#            src_dump_path="$local_dump_path"
#            src_uploads_path=$dev_uploads_path
#        elif [[ "$location" == "stage" ]]; then
#            src_db_user=$stage_db_user
#            src_password=$stage_password
#
#            src_ssh_args=$stage_ssh_args
#            src_branch="$BRANCH"
#            src_comparedb="$DB_USER:$DB_PASSWORD@$HOST_SQL"
#            src_url=$URL
#            src_mysql_args_nh=$stage_mysql_args_nh
#            src_db=$stage_db
#            src_path=$stage_path
#            tmp=$(ssh -t $src_ssh_args pwd 2>/dev/null)
#            tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
#            src_dump_path="$tmp/$db_folder"
#            src_uploads_path=$stage_uploads_path

#       1 'db' create database (install wordpress? no)
#       2 'git' create git repo at location
#       3 'git_main' create main git repo
#       4 'ht' make .htaccess
#       5 'robots' robots.txt
#       6 'config' wp-config.php
#       7 'wp' wordpress files
#       8 'files' all files 4-7
#       9 'all' except git_main
#       10 'new' all and git_main 
    setLocationVariables(){
        compare_db_name="compare_$DB_NAME"
        sei="--skip-extended-insert"
        no_create_tables="--skip-add-drop-table --skip-extended-insert --no-create-info --insert-ignore"
        no_data="--skip-add-drop-table --skip-extended-insert --insert-ignore --no-data"

        mysql_args="-h$HOST_SQL -u$DB_USER --password=\"$DB_PASSWORD\""

#        mysql_args="-hlocalhost -u$DB_USER --password=$DB_PASSWORD" 

 #       mysql_args_nh="-h$HOST_SQL -u$DB_USER --password=$DB_PASSWORD" 
        mysql_args_nh="-hlocalhost -u$DB_USER --password=\"$DB_PASSWORD\""

        db="$DB_NAME"

        path=${FULL_PATH%/}
        uploads_dir="wp-content/uploads"
        uploads_path="$path/$uploads_dir"

        if [[ -n "$USER_SSH"  ]]; then
            ssh_args="$USER_SSH@$HOST_SSH"
        else
            ssh_args=""
        fi
        ssh_port=$HOST_SSH_PORT

        dump_name="dump.sql"
        db_folder="db_$current_site"
        wp_prefix=$WP_PREFIX
        echo "wp_prefix=$WP_PREFIX"

        if [[ -z "$wp_prefix" ]]; then
            wp_prefix='wp_'
        fi

        branch="$BRANCH"
        comparedb="$DB_USER:$DB_PASSWORD@$HOST_SQL"
        url=$URL

        #unset all variables
        DB_NAME=
        HOST_SQL=
        DB_USER=
        DB_PASSWORD=
        DB_NAME=
        FULL_PATH=
        USER_SSH=
        HOST_SSH=
        HOST_SSH_PORT=
#        WP_PREFIX=

    }


    #paths
    #name
    sourceFileWithName(){
        local site_vars_array=("${!1}")
        local name=$2
        local path=""
        local tmp=""
        for path in "${site_vars_array[@]}"; do
            tmp=$(basename $path)
            if [[ $name = ${tmp%.sh} ]]; then
                sourceVars $path
            fi
        done
    }


    #source variables:
    getSetupSrc(){
        local loc=$1
#       for moo in ${locations[@]}; do
#           echo "before: $moo"
#       done
        getLocationNames locations "site_vars_array[@]"
        if $(isInOpts "locations[@]" "$loc" ); then
            printf "loc: $loc"
            sourceFileWithName "site_vars_array[@]" "$loc"
            setLocationVariables
            src_ssh_port=$ssh_port
            if [[ -n $src_ssh_port ]]; then
                src_ssh_args="$ssh_args -p $src_ssh_port"
            else
                src_ssh_args="$ssh_args"
            fi
            src_scp_args="$ssh_args"
            src_branch="$branch"
            src_comparedb="$comparedb"
            src_url=$url
            src_mysql_args=$mysql_args
            src_mysql_args_nh=$mysql_args_nh
            src_db=$db
            src_path=$path
            src_git_url="git@bitbucket.org:viridiantech/$GIT_NAME.git" 
            src_git_name=$GIT_NAME 
            if [[ -n "$src_scp_args" ]]; then
                local tmp=$(ssh -t $src_ssh_args "pwd && mkdir -p '$db_folder'" 2>/dev/null)
#                local tmp=$(ssh -t $src_ssh_args pwd 2>/dev/null)
                tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
                src_dump_path="$tmp/$db_folder"
            else
                src_dump_path="$local_dump_path"
            fi
            src_uploads_path=$uploads_path

        else
            printf "Not a valid option for source: '$src'"
            abort 1
        fi
    }

#    getSetupSrc


    if $(isInOpts "options_array[@]" 'db'); then
        printf "db is in opts \n\n"
        delete_and_create_db "$src_ssh_args" "$src_mysql_args_nh" "$src_db"
    fi

    if $(isInOpts "options_array[@]" 'wp'); then
        printf "wp is in opts \n\n"
        #delete_and_create_db "$src_ssh_args" "$src_mysql_args_nh" "$src_db"
        makeWordpress "$src_ssh_args"  "$src_path" 
    fi
    
    if $(isInOpts "options_array[@]" 'config'); then
        printf "config is in opts \n\n"
        makeConfig "$src_ssh_args" "$src_path"
    fi

    if $(isInOpts "options_array[@]" 'htaccess'); then
        makeOrMoveHtaccess "$dest_ssh_args" "$src_path" "$current_site_path" "$location" "$dest_ssh_args" "$src_path" "$folder_name" 
    fi

    if $(isInOpts "options_array[@]" 'git'); then
        printf "git is in opts \n\n"
        makeGit "$src_ssh_args" "$src_path" "$git_url"
    fi

    if $(isInOpts "options_array[@]" 'git_main'); then
        printf "git_main is in opts \n\n"
    fi

    if $(isInOpts "options_array[@]" 'all'); then
        printf "all is in opts \n\n"
        delete_and_create_db "$src_ssh_args" "$src_mysql_args_nh" "$src_db"
        makeWordpress "$src_ssh_args"  "$src_path" 
        makeConfig "$src_ssh_args" "$src_path" "$src_db" "$src_db_user" "$src_password"
        makeOrMoveHtaccess "$dest_ssh_args" "$src_path" "$current_site_path" "$location" "$dest_ssh_args" "$src_path" "$folder_name" 
        makeGit "$src_ssh_args" "$src_path" "$git_url"
    fi

    if $(isInOpts "options_array[@]" 'new'); then
        printf "all is in opts \n\n"
        delete_and_create_db "$src_ssh_args" "$src_mysql_args_nh" "$src_db"
        makeWordpress "$src_ssh_args"  "$src_path" 
        makeConfig "$src_ssh_args" "$src_path" "$src_db" "$src_db_user" "$src_password"
        makeOrMoveHtaccess "$dest_ssh_args" "$src_path" "$current_site_path" "$location" "$dest_ssh_args" "$src_path" "$folder_name" 
        makeGit "$src_ssh_args" "$src_path" "$git_url"
    fi



    done 

<<COMMENT1  
#wordpress:
mkdir -p /srv/http/sitename
cd /srv/http/sitename
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz 
cd wordpress
cp -rf . ..
cd ..
rm -rf wordpress
rm latest.tar.gz


#htaccess
make .htaccess file
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /sitename/
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /sitename/index.php [L]
</IfModule>

#optional theme thing
mv themefile.zip sitename/wp-content/themes
cd sitename/wp-content/themes
unzip themefile.zip
rm themefile.zip
cd sitename/wp-content

#wp-config
mv  wp-config-sample.php wp-config.php
change wp-config.php
1 change db creds
2 change keys
3 change table prefix

#database
mysql -uuser -ppassword -e "create database sitename"
if on staging or prod download other files like robots.txt
find sitename -type d -exec chmod 755 {} \;
o change all the files to 644 (-rw-r--r--):
 find theloveoftruth/ -type d -exec chmod 755 {} \;
find /opt/lampp/htdocs -type f -exec chmod 644 {} \;
COMMENT1
  
  #  if [[ "$dest" == "dev" ]]; then
  #    dest_ssh_args=$dev_ssh_args
  #    dest_branch="$BRANCH"
  #    dest_comparedb="$DB_USER:$DB_PASSWORD@localhost"
  #    dest_url=$URL
  #    #dest_mysql_args=$dev_mysql_args
  #    dest_mysql_args_nh=$dev_mysql_args_nh
  #    dest_db=$dev_db
  #    dest_path=$dev_path
  #    dest_dump_path=$local_dump_path
  #    dest_uploads_path=$dev_uploads_path
  #  elif [[ "$dest" == "stage" ]]; then
  #    dest_ssh_args=$stage_ssh_args
  #    dest_branch="$BRANCH"
  #    dest_comparedb="$DB_USER:$DB_PASSWORD@$HOST_SQL"
  #    dest_url=$URL
  #    #dest_mysql_args=$stage_mysql_args
  #    dest_mysql_args_nh=$stage_mysql_args_nh
  #    dest_db=$stage_db
  #    dest_path=$stage_path
  #    tmp=$(ssh -t $dest_ssh_args "pwd && mkdir -p '$db_folder'" 2>/dev/null)
  #    tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
  #    dest_dump_path=$tmp/$db_folder
  #    dest_uploads_path=$stage_uploads_path
  #  elif [[ "$dest" == "prod" ]]; then
  #    dest_ssh_args=$prod_ssh_args
  #    dest_branch="$BRANCH"
  #    dest_comparedb="$DB_USER:$DB_PASSWORD@$HOST_SQL"
  #    dest_url=$URL
  #    #dest_mysql_args=$prod_mysql_args
  #    dest_mysql_args_nh=$prod_mysql_args_nh
  #    dest_db=$prod_db
  #    dest_path=$prod_path
  #    tmp=$(ssh -t $dest_ssh_args "pwd && mkdir -p '$db_folder'" 2>/dev/null)
  #    tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
  #    dest_dump_path=$tmp/$db_folder
  #    dest_uploads_path=$prod_uploads_path
  #  elif [[ "$dest" == "stage2" ]]; then
  #    dest_ssh_args=$stage_ssh_args2
  #    dest_branch="$BRANCH2"
  #    dest_comparedb="$DB_USER2:$DB_PASSWORD2@$HOST_SQL2"
  #    dest_url=$URL2
  #    #dest_mysql_args=$stage_mysql_args
  #    dest_mysql_args_nh=$stage_mysql_args_nh2
  #    dest_db=$stage_db2
  #    dest_path=$stage_path2
  #    tmp=$(ssh -t $dest_ssh_args2 "pwd && mkdir -p '$db_folder2'" 2>/dev/null)
  #    tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
  #    dest_dump_path=$tmp/$db_folder2
  #    dest_uploads_path=$stage_uploads_path2
  #  elif [[ "$dest" == "prod2" ]]; then
  #    dest_ssh_args=$prod_ssh_args2
  #    dest_branch="$BRANCH2"
  #    dest_comparedb="$DB_USER2:$DB_PASSWORD2@$HOST_SQL2"
  #    dest_url=$URL2
  #    #dest_mysql_args=$prod_mysql_args
  #    dest_mysql_args_nh=$prod_mysql_args_nh2
  #    dest_db=$prod_db2
  #    dest_path=$prod_path2
  #    tmp=$(ssh -t $dest_ssh_args2 "pwd && mkdir -p '$db_folder2'" 2>/dev/null)
  #    tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
  #    dest_dump_path=$tmp/$db_folder2
  #    dest_uploads_path=$prod_uploads_path2
  #  else
  #    printf "Not a valid option for destination: '$dest'"
  #    abort 1
  #  fi
  
  
    
  #  if $(isInOpts "options_array[@]" 'all'); then
  #    printf "all is in opts \n\n"
  #    scp_copy "$src_ssh_args" "$src_uploads_path" "$dest_ssh_args" "$dest_uploads_path" "-r" "*"
  #    copy_db "$src_dump_path" "$dest_dump_path" "$WP_PREFIX"
  #    git_pull "$dest_branch" "$dest_path" "$dest_ssh_args" 
  #  fi
  #  
  #  if $(isInOpts "options_array[@]" 'db'); then
  #    printf "db is in opts \n\n"
  #    copy_db "$src_dump_path" "$dest_dump_path" "$WP_PREFIX"
  #  fi
  #  
  #  if $(isInOpts "options_array[@]" 'up'); then
  #    printf "up is in opts \n\n"
  #    scp_copy "$src_ssh_args" "$src_uploads_path" "$dest_ssh_args" "$dest_uploads_path" "-r" "*"
  #  fi
  #  
  #  if $(isInOpts "options_array[@]" 'updb'); then
  #    printf "updb is in opts \n\n"
  #    scp_copy "$src_ssh_args" "$src_uploads_path" "$dest_ssh_args" "$dest_uploads_path" "-r" "*"
  #    copy_db "$src_dump_path" "$dest_dump_path" "$WP_PREFIX"
  #  fi
  #  
  #  if $(isInOpts "options_array[@]" 'git'); then
  #    printf "git is in opts \n\n"
  #    #printf "$dest_path \n"
  #    #printf "$dest_ssh_args \n"
  #    git_pull "$dest_branch" "$dest_path" "$dest_ssh_args" 
  #  fi
  #  
  #  if $(isInOpts "options_array[@]" 'dumpdb'); then
  #    printf "dumpdb is in opts \n\n"
  #    dumpdb "$src_ssh_args" "$src_mysql_args_nh $sei $src_db" "$src_dump_path/dump_skip_extended_insert.sql"
  #    dumpdb "$src_ssh_args" "$src_mysql_args_nh $no_data $src_db" "$src_dump_path/dump_no_data.sql"
  #    dumpdb "$src_ssh_args" "$src_mysql_args_nh $no_create_tables $src_db" "$src_dump_path/dump_no_create_tables.sql"  
  #  fi
  #  
  #  if $(isInOpts "options_array[@]" 'mysqldbcompare'); then
  #    printf "mysqldbcompare is in opts \n\n"
  #    mysqldbcompare_dbs "$src_comparedb" "$dest_comparedb" "$compare_db_name:$DB_NAME" "--changes-for=server1 --difftype=sql --run-all-tests" "compare_$dump_name"
  #  fi
  
}

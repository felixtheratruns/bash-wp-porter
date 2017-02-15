#!/usr/bin/env bash

#    This file is part of the bash version of "Porter." 
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
#    along with Porter.  If not, see <http://www.gnu.org/licenses/>.

#this will need to be uncommented:
#shopt -s extglob
#if you want the following command to work:
#cmnd_np="${cmnd//--password=+([! ])/--password=XXXXX}"
#
#echo "meow $_base_vars"
#echo " $__script_dir"
#echo " $_base_vars"
#echo " $_remote_vars_name"
#echo " $_sites_directory"

rot(){ 
    declare cmnd=$* 
    declare ret_code 
    #this if there are quotes arround password: 
    #echo "$value"|sed 's/password="[^"]*"/password="XXXXX"/' >> somelog.log 
    if [[ "$showpass" = 0 ]]; then
        local cmnd_np=$(echo "$cmnd" | sed 's/password=[^ ]*/password=XXXXX/') 
    else
        local cmnd_np="$cmnd"
    fi
    #  cmnd_np="${cmnd//--password=+([! ])/--password=XXXXX}" 
    #  echo "run status -- $run_status"
    if [ "$run_status" = 1  ]; then 
        echo "cmnd=$cmnd_np" 
        eval $cmnd 
        #`$cmnd` 
        ret_code=$? 
        printf "\n\n" 
        if [ $ret_code != 0 ]; then 
            printf "Return code: Error : ['$ret_code'] when executing command: '$cmnd'\n\n" 
            exit $ret_code 
        fi 
    elif [ "$run_status" = 0 ]; then
        echo "test=$cmnd_np" 
        printf "\n\n" 
    else
        printf "invalid run status: $run_status"
        printf "\n\n"
    fi 
} 

 
return_val(){ 
    local __resultvar=$1 
    declare cmnd="${*:2}"

    if [[ "$showpass" = 0 ]]; then
        local cmnd_np=$(echo "$cmnd" | sed 's/password=[^ ]*/password=XXXXX/') 
    else
        local cmnd_np="$cmnd"
    fi

    if [[ "$run_status" = 1 ]]; then
        echo "output of cmnd=$cmnd_np"    
        echo "stored in $__resultvar"    
        eval $__resultvar='"`$cmnd`"'
        #$__resultvar=`$cmnd` 
        ret_code=$? 
        if [ $ret_code != 0 ]; then 
            printf "Return code: Error : ['$ret_code'] when executing command: '$cmnd'\n\n" 
            exit $ret_code 
        fi 
        echo "result=$__resultvar"
    elif [[ "$run_status" = 0 ]]; then
        echo "output of test=$cmnd_np"    
        echo "would be stored in $__resultvar"    
        printf "\n\n"
    else
        printf "invalid run status: $run_status"
        printf "\n\n"
    fi 
} 
 
rot_test(){ 
    declare cmnd="$1" 
    declare suc_mesg="$2" 
    declare err_mesg="$3" 
    declare ret_code 
    eval "$cmnd" 
    ret_code=$? 
    printf "\n\n" 
    if [ $ret_code != 0 ]; then 
        cmnd_np=$(echo "$cmnd" | sed 's/password=[^ ]*/password=XXXXX/') 
    #    local cmnd_np="${cmnd//--password=+([! ])/--password=XXXXX}" 
        printf "TEST: Error : ['$ret_code'] when executing command: '$cmnd_np'\n" 
        printf "$err_mesg \n\n" 
        exit $ret_code 
    else 
        printf "$suc_mesg \n\n" 
    fi 
}

sourceVars(){
    local base_vars_path=$1
    if [ -e "$base_vars_path" ]; then
        printf "sourcing: $base_vars_path\n\n"
        source "$base_vars_path" 
    else
        printf "sourceVars WARNING: you have no $base_vars_path\n\n"
    fi
}


writeBaseVars(){
  local current_site=$1
#  local local_vars_name=$2
  printf "writing to file . . . \n"
  printf '#!/bin/bash\n' > $_base_vars_path
  printf "current_site=\"$current_site\"\n\n" >> "$_base_vars_path"
#  printf "local_vars_name=\"$local_vars_name\"\n\n" >> "$_base_vars_path"
  printf "current_site=\"$current_site\"\n"
#  printf "local_vars_name=\"$local_vars_name\"\n"
#  rot source "$_base_vars"
}

setCurrentSite(){
    local set_site=`basename ${1%/}`
    local script_dir=$2
    local sites_directory=$3
    local run_status=$4
    local base_vars_path=$5
    local remote_vars_name=$6
    local site_vars_array=("${!7}")  
    sourceVars "$base_vars_path"
 
#    if [ -z "$local_vars_name"  ]; then
#        printf "What is the name of your local var file?\n"
#        printf "name it anything except $remote_vars_name\n\n"
#        read -r -p "local_vars_name:" local_vars_name
#        echo "writeBaseVars $set_site $local_vars_name"
#        writeBaseVars "$set_site" "$local_vars_name"

#        remote_vars="$script_dir/../$sites_directory/$current_site/$remote_vars_name"
#        local_vars="$script_dir/../$sites_directory/$current_site/$local_vars_name"
      
        if [ -z "$current_site"  ] ||  [ "$current_site" != "$set_site" ]; then
            printf "$current_site is different than $set_site\n"
            #not needed because we don't know if we should delete them currently
#           printf "therefore deleting vars of $current_site (if any exist)\n"
#           if [ -e "$remote_vars" ]; then
#               printf "deleting: $remote_vars\n"
#               rot rm "$remote_vars"
#           fi
#       
#           if [ -e "$local_vars" ]; then
#               printf "deleting: $local_vars\n"
#               rot rm "$local_vars" 
#           fi
            current_site=$set_site
            writeBaseVars "$current_site"
            printf "WARNING, CURRENT SITE CHANGED: $current_site\n\n"
        fi 
  
    for i in "${site_vars_array[@]}" 
    do 
        test_encrypt "$i"
    done 
    abort 0
}

getPathToSite(){
  local current_site=${1%/}
  local script_dir=$2
  echo "$_script_dir/$current_site"
}

#1 source vars
#2 test if there as vars
#3 make paths for stuff

#1 source vars
#2 test if vars

prepareVars(){
#    local __resultvar=$1
    local script_dir=$2
    local sites_directory=$3
    local remote_vars_name=$4
    local base_vars_path=$5
    local in_site=$6
  
    sourceVars "$base_vars_path"  
  
    #overwrite current_site variable if set
    if [[ -n "$in_site" ]]; then
      current_site=$in_site
    fi
  
#    if [ -z "$local_vars_name"  ]; then
#        printf "What is the name of your local var file?\n"
#        printf "name it anything except $remote_vars_name\n\n"
#        read -r -p "local_vars_name:" local_vars_name
#        writeBaseVars "$current_site" "$local_vars_name"
#    fi
  
    if [ -z "$current_site" ]; then
        printf "What is the name of your current site?\n"
        read -r -p "current_site:" current_site
        writeBaseVars "$current_site" 
    fi
#    eval $__resultvar+="('$local_vars_name')" 
}

makeVarArr(){
    local __resultvar=$1
    local script_dir=$2
    local sites_directory=$3
    local site=$4
    local site_vars_names=("${!5}")  
    site_vars_names=()
    for i in "$script_dir/$sites_directory/$site/"*.sh; do
        local tmp=$(basename "$i")
        site_vars_names+=($tmp)
    done

    local site_vars_paths=()
    for i in "${site_vars_names[@]}"; do
        site_vars_paths+=("$script_dir/$sites_directory/$site/$i")
    done  
    #arr+=('')
    #local_dump_path="$_script_dir/$current_site"
    #local remote_vars="$_script_dir/$sites_directory/$current_site/$remote_vars_name"
    #local local_vars="$_script_dir/$sites_directory/$current_site/$local_vars_name"
    #arr=("$local_vars" "$remote_vars")
    eval $__resultvar='( "${site_vars_paths[@]}" )'
}

abort()
{
exit_out=$1
    if [ 0 != "$exit_out" ]; then
            echo >&2 '
        ***************
        *** ABORTED ***
        ***************
        '
        printf "An error occurred. Exiting... \n">&2
        printf "script exited: `date +%Y-%m-%d:%H:%M:%S`\n"
        printf "exit: $exit_out  \n"
        exit $exit_out
    else
        echo >&2 '
        ************
        *** DONE *** 
        ************
        '
        printf "Everything went as expected: Exiting...\n">&2
        printf "script exited: `date +%Y-%m-%d:%H:%M:%S`\n"
        printf "exit: $exit_out  \n"
        exit $exit_out
    fi
}

function EIR(){
  if [ "$run_status" = 1 ]; then
    printf $1
  fi
}

#test if in opts
function isInOpts()
{
    local arr=("${!1}")  
    local input=$2
    local output=false
    for i in ${arr[@]}; do
        if [[ "$i" == "$input" ]]; then
            output=true
        fi
    done
    echo $output
}

getSet()
{
    local input=$1
    local output=""
    for i in "${opt_arr[@]}"; do
        if [ $i == $input  ]; then
            output=$(echo "$i" | cut -d '=' -f 2-)
        fi
    done
    echo $output
}

function printusage(){
    printf "normal 4 argument usage (same as test mode except with 'run' at the end): ./websiteadmin.sh [option,option,...] [source server] [destination server] run\n"
    printf "usage for test mode: ./websiteadmin.sh [option,option,...] [source server] [destination server]\n"
    printf "e.g. the following moves database and uploads from dev to stage and updates git on staging: \n"
    printf "./websiteadmin.sh db,git,up dev stage \n"
    printf "e.g. does database uploads and git_pull: \n"
    printf "./websiteadmin.sh all dev prod \n"
    printf "e.g.: ./websiteadmin.sh git stage\n"
    printf "source server: dev, stage, prod \n"
    printf "destination server: dev, stage, prod \n"
    printf "'option: all, db, up, updb, git, dumpdb, mysqldbcompare, buildcompare, mergedb, comparemerge, setvars'\n"
    printf "'all' does everything related to changing destination server, database, uploads, and git pull \n"
    printf "'db' just copies database \n"
    printf "'up' just copies uploads \n"
    printf "'updb' copies both uploads and db \n"
    printf "'git' just does git pull in the destination \n"
    printf "'dumpdb' dumps source db to sql file in the site folder\n"
    printf "'setvars' setup a vars.sh \n"
    printf "'set=[site folder name]' this will set the site you are working with \n"
    printf "     it may ask you to decrypt vars, this will also delete the unencrypted vars in the site folder \n"
    printf "'enc=[site folder name]' this will encrypt the vars you have put in that site folder (overwriting any encrypted vars) \n"
    printf "'setvars' setup a vars.sh and remote_vars.sh for the site folder you are working in \n"

}

function url_change(){
    local ssh_args=$1
    local newurl_nq=$2
    local mysql_args=$3
    local newurl="$newurl_nq"
    local post_prefix=$4
    local port=$5
    local options='options'
    local posts='posts'
    local postmeta='postmeta'
    local wp_options=$post_prefix$options
    local wp_posts=$post_prefix$posts
    local wp_postmeta=$post_prefix$postmeta   

    #setup port arg if port exists
    if [[ -n $port ]]; then
        local port_arg=" -p $port"   
    else
        local port_arg=""
    fi

    #setting up mysql args so the quotes don't make the command fail
    local start_mysql=$(echo $mysql_args | cut -d \" -f1)
    local pass=$(echo $mysql_args | cut -d \" -f2)
    local end_mysql=$(echo $mysql_args | cut -d \" -f3)
    mysql_args=$start_mysql"$pass"$end_mysql

    local query_t=
     
    if [ -n "$ssh_args" ]; then
        #query_t=`ssh -t $ssh_args$port_arg "mysql -s -N $mysql_args -e \"SELECT option_value FROM $wp_options WHERE option_name = 'siteurl';\"" 2>/dev/null`
        return_val query_t ssh -t $ssh_args$port_arg "mysql -s -N $mysql_args -e \"SELECT option_value FROM $wp_options WHERE option_name = 'siteurl';\" 2>/dev/null"
    else
        query_t=$(mysql -s -N $mysql_args  -e "SELECT option_value FROM $wp_options WHERE option_name = 'siteurl';" 2>/dev/null)
#        return_val query_t mysql -s -N $mysql_args -e 'SELECT option_value FROM $wp_options WHERE option_name = 'siteurl';' 2>/dev/null
    fi
    local query=${query_t//[^a-zA-Z0-9_:\.\/\-\~]/}
 
    local tmp=($query)
    local siteurl_nq=${tmp[0]}
    local siteurl="$siteurl_nq"
    printf "current url is in \"query_t\"\n\n"
    printf "current url: $siteurl\n"
    printf "     newurl: $newurl\n\n"
  
    if [ "$run_status" = 1 ]; then
      if [ -n "$ssh_args" ]; then
        printf "cmnd=$(echo "ssh -t $ssh_args$port_arg mysql $mysql_args -e \"\"UPDATE $wp_options SET option_value = REPLACE(option_value, '$siteurl', '$newurl') WHERE option_name = 'home' OR option_name = 'siteurl'; UPDATE $wp_posts SET guid = REPLACE(guid, '$siteurl', '$newurl'); UPDATE $wp_posts SET post_content = REPLACE(post_content, '$siteurl', '$newurl'); UPDATE $wp_postmeta SET meta_value = REPLACE(meta_value, '$siteurl', '$newurl');\"\"" |  sed 's/password=[^ ]*/password=XXXXX/') \n\n"
        ssh -t $ssh_args$port_arg mysql $mysql_args -e "\"UPDATE $wp_options SET option_value = REPLACE(option_value, '$siteurl', '$newurl') WHERE option_name = 'home' OR option_name = 'siteurl'; UPDATE $wp_posts SET guid = REPLACE(guid, '$siteurl', '$newurl'); UPDATE $wp_posts SET post_content = REPLACE(post_content, '$siteurl', '$newurl'); UPDATE $wp_postmeta SET meta_value = REPLACE(meta_value, '$siteurl', '$newurl');\""
      else
        printf "cmnd=$(echo "mysql $mysql_args -e \"\"UPDATE $wp_options SET option_value = REPLACE(option_value, '$siteurl', '$newurl') WHERE option_name = 'home' OR option_name = 'siteurl'; UPDATE $wp_posts SET guid = REPLACE(guid, '$siteurl', '$newurl'); UPDATE $wp_posts SET post_content = REPLACE(post_content, '$siteurl', '$newurl'); UPDATE $wp_postmeta SET meta_value = REPLACE(meta_value, '$siteurl', '$newurl');\"\"" |  sed 's/password=[^ ]*/password=XXXXX/') \n\n"
        mysql $mysql_args -e "UPDATE $wp_options SET option_value = REPLACE(option_value, '$siteurl', '$newurl') WHERE option_name = 'home' OR option_name = 'siteurl'; UPDATE $wp_posts SET guid = REPLACE(guid, '$siteurl', '$newurl'); UPDATE $wp_posts SET post_content = REPLACE(post_content, '$siteurl', '$newurl'); UPDATE $wp_postmeta SET meta_value = REPLACE(meta_value, '$siteurl', '$newurl');"
      fi
    else
      if [ -n "$ssh_args" ]; then
        rot ssh -t $ssh_args$port_arg mysql $mysql_args -e "\"UPDATE $wp_options SET option_value = REPLACE(option_value, '$siteurl', '$newurl') WHERE option_name = 'home' OR option_name = 'siteurl'; UPDATE $wp_posts SET guid = REPLACE(guid, '$siteurl', '$newurl'); UPDATE $wp_posts SET post_content = REPLACE(post_content, '$siteurl', '$newurl'); UPDATE $wp_postmeta SET meta_value = REPLACE(meta_value, '$siteurl', '$newurl');\""
      else 
        rot mysql $mysql_args -e "UPDATE $wp_options SET option_value = REPLACE(option_value, '$siteurl', '$newurl') WHERE option_name = 'home' OR option_name = 'siteurl'; UPDATE $wp_posts SET guid = REPLACE(guid, '$siteurl', '$newurl'); UPDATE $wp_posts SET post_content = REPLACE(post_content, '$siteurl', '$newurl'); UPDATE $wp_postmeta SET meta_value = REPLACE(meta_value, '$siteurl', '$newurl');"
      fi
    fi
}

function deletedb(){
    local ssh_args="$1"
    local mysql_args="$2"
    local db_name="$3"
    local ssh_port=$4
  
    if [[ -n "$ssh_port" ]]; then
        local ssh_port_arg=" -p $ssh_port"            
    else
        local ssh_port_arg="" 
    fi 
  
    if [[ -n "$ssh_args" ]]; then
      rot "ssh -t $ssh_args$ssh_port_arg mysqladmin -f -v $mysql_args drop \"$db_name\"" 
    else
      rot "mysqladmin -f -v $mysql_args drop \"$db_name\""
    fi
}

function createdb(){
    local ssh_args="$1"
    local mysql_args="$2"
    local db_name="$3"
    local ssh_port=$4
   
    if [[ -n "$ssh_port" ]]; then
        local ssh_port_arg=" -p $ssh_port"            
    else
        local ssh_port_arg="" 
    fi 
 
    if [[ -n "$ssh_args" ]]; then
      rot  "ssh -t $ssh_args$ssh_port_arg mysqladmin -f -v $mysql_args create \"$db_name\""
    else 
      rot "mysqladmin -f -v $mysql_args create \"$db_name\""
    fi
}

function delete_and_create_db(){
    local ssh_args=$1
    local mysql_args=$2
    local db_name=$3
    local ssh_port=$4
    local ssh_backup=$ssh_args

    if [[ -n $ssh_port ]]; then
       local port_arg="-p $ssh_port" 
    fi

    if [[ -n "$ssh_args" ]]; then
        local query=$(ssh -t $ssh_args$port_arg mysql $mysql_args -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$db_name'" 2>&1); 
    else
        local query=$(mysql $mysql_args -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$db_name'" 2>&1); 
    fi
    
    ssh_args=$ssh_backup 
    if [[ -n "$query" ]]; then 
        printf "db does exist: $db_name \n";
        printf "deleting and creating: $db_name \n\n";
        deletedb "$ssh_args" "$mysql_args" "$db_name" "$ssh_port"
        createdb "$ssh_args" "$mysql_args" "$db_name" "$ssh_port"
    else
        printf "creating database: $db_name \n\n"; 
        createdb "$ssh_args" "$mysql_args" "$db_name" "$ssh_port"    
    fi   
}

function create_db_or_error(){
    local ssh_args=$1
    local mysql_args=$2
    local db_name=$3
    if [ -n "$ssh_args" ]; then
        local query=$(ssh -t $ssh_args mysql $mysql_args -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$db_name'" 2>&1); 
    else
        local query=$(mysql $mysql_args -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$db_name'" 2>&1); 
    fi
  
    if [ -z "$query" ]; then 
        printf "creating database: $db_name \n\n"; 
        createdb "$ssh_args" "$mysql_args" "$db_name"     
    else
        printf "DB already exists: $db_name \n";
        abort 1
        #deletedb "$ssh_args" "$mysql_args" "$db_name"
        #createdb "$ssh_args" "$mysql_args" "$db_name"
    fi   
}

function no_dump_file(){
  local src_mysql_args=$1
  local dest_mysql_args=$2
  rot "mysqldump -f -v $src_mysql_args | mysql -f $dest_mysql_args" 
}

function dumpdb(){
    local ssh_args=$1
    local mysql_args=$2
    local dump_path=$3
    local ssh_port=$4
  
    if [[ -n $ssh_port ]]; then
        ssh_port_arg=" -p $ssh_port"    
    else
        ssh_port_arg=""    
    fi  
  
    if [ -n "$ssh_args" ]; then
        rot "ssh -t $ssh_args$ssh_port_arg 'mysqldump -f -v $mysql_args > '$dump_path''"
    else 
        rot "mysqldump -f -v $mysql_args > '$dump_path'"
        if [[ -n $port ]]; then
            echo "WARING: port given but not used because no ssh args"
        fi 
    fi
}

function restoredb(){
    local ssh_args="$1"
    local mysql_args="$2"
    local dump_path="$3"
    local ssh_port="$4"

    if [[ -n $ssh_port  ]]; then
        local ssh_port_arg=" -p $ssh_port"    
    else
        local ssh_port_arg=""
    fi 
 
    if [ -n "$ssh_args" ]; then
      rot "ssh -t $ssh_args$ssh_port_arg 'mysql -f $mysql_args < '$dump_path''"
    else 
      rot "mysql -f $mysql_args < '$dump_path'"
    fi 
}

function update_compare(){
    local args="$1"
    local dump_path="$2"
    rot "mysql -f $args < $dump_path"
}

function test_dir(){
    rot_test "cd '$dir'" "You are able to get to $dir" "You are not able to get to $dir"  
}

function test_args(){
    local args="$1"
    local dir="$2"
    if [ -n "$args" ]; then
      rot_test "ssh -o BatchMode=yes -o ConnectTimeout=5 $args : " "You are able to login to '$args'" "You are not able to login to '$args'"
      rot_test "ssh -o BatchMode=yes -o ConnectTimeout=5 $args 'cd $dir'" "You are are also able to get to: '$dir'" "You are about to login to: '$args' but not able to get to: '$dir'"
    else
      test_dir "$dir"
    fi 
}

function scp_copy(){
    local src_sep=":"
    local dest_sep=":"
    local src_ssh_args="$1"
    local src_dir="$2"
    local dest_ssh_args="$3"
    local dest_dir="$4"
    local flags="$5"
    local postfix="$6"
    local src_ssh_port="$7"
    local dest_ssh_port="$8"
    local local_dump_path="$9"

    local b_scr_dir=$(basename $src_dir)
    local b_dest_dir=$(basename $dest_dir)

    if [[ -n $src_ssh_port ]]; then
        local src_scp_port_arg="-e \"ssh -p $src_ssh_port\""
        local src_ssh_port_arg="-p $src_ssh_port"
    fi

    if [[ -z $src_scp_port_arg ]]; then
        echo "nothing in the \$src_scp_port_arg variable"
    fi

    if [[ -n $dest_ssh_port ]]; then
        local dest_scp_port_arg="-e \"ssh -p $dest_ssh_port\""    
        local dest_ssh_port_arg="-p $dest_ssh_port"
    fi

    if [[ -z $dest_scp_port_arg ]]; then
        echo "nothing in the \$dest_scp_port_arg variable"
    fi

#    local src_ssh_args_port="$src_scp_port_arg $src_ssh_args" 
#    local dest_ssh_args_port="$dest_port_arg $dest_ssh_args" 
 
    if [[ -z "$src_ssh_args" ]]; then
        local src_sep=""
        local src_is_local=true
    else
        local src_is_local=false
    fi
  
    if [[ -z "$dest_ssh_args" ]]; then
        local dest_sep=""
        local dest_is_local=true
    else
        local dest_is_local=false
    fi
   
    if [[ -n "$src_ssh_args" ]] && [[ -n "$dest_ssh_args" ]] && [[ "$src_ssh_args$src_ssh_port_arg" = "$dest_ssh_args$dest_ssh_port_arg" ]]; then
        #working on same server with same login
    #rot "ssh -t $src_ssh_args scp -r '$src_dir/'$postfix '$dest_dir/'"
        #this tests 1 if the source exists, 2 if there is anything in the source directory
        if $(ssh $src_ssh_args $src_ssh_port_arg '[[ -d '$src_dir/' ]] && [[ $(ls -A '$src_dir/') ]]' 2>/dev/null); then
            if [[ "$dest_dir" = "$src_dir"  ]]; then
                :     
            else
                rot "ssh -t $src_ssh_args $src_ssh_port_arg 'mkdir -p '$dest_dir/' && rsync -rlzvP '$src_dir/' '$dest_dir/''"
            fi
        else
            printf "4 $src_ssh_port_arg $src_ssh_args:$src_dir/ is empty or does not exist, scp not needed to run \n\n" 
        fi
    else
        if $src_is_local; then    
            if [[ -d "$src_dir/" ]] && [[ "`ls -A "$src_dir/"`" ]]; then    
                if $dest_is_local; then
                    rot mkdir -p "$dest_dir/" 
                    rot "rsync -rlzvP $flags $src_scp_port_arg '$src_ssh_args$src_sep$src_dir/' '$dest_dir/'" 
                else 
                    rot "ssh -t $dest_ssh_args $dest_ssh_port_arg mkdir -p '$dest_dir/'" 
                    rot mkdir -p "$local_dump_path/" 
                    #rot "rsync -rlzvP $flags $src_scp_port_arg '$src_ssh_args$src_sep$src_dir/'$postfix '$local_dump_path/'" 
                    if [[ $src_dir != $local_dump_path  ]]; then
                        rot "rsync -rlzvP '$src_dir/' '$local_dump_path/'" 
                    fi
                    rot "rsync -rlzvP $flags $dest_scp_port_arg '$local_dump_path/' '$dest_ssh_args$dest_sep$dest_dir/'" 
                    rot "rm -r '$local_dump_path/'$postfix" 
                fi
                #scp copy 
                #rot "scp -3 $flags $src_scp_port_arg '$src_ssh_args$src_sep$src_dir/'$postfix$dest_port_arg '$dest_ssh_args$dest_sep$dest_dir/'"
            else
                printf "5 source $src_dir/ does not exist or is empty, scp not needed \n\n" 
            fi 
        else
            if $(ssh $src_ssh_args $src_ssh_port_arg '[[ -d '$src_dir/' ]] && [[ $(ls -A '$src_dir/') ]]' 2>/dev/null); then    
                if $dest_is_local; then
                    rot mkdir -p "$dest_dir/" 
                    rot "rsync -rlzvP $flags $src_scp_port_arg '$src_ssh_args$src_sep$src_dir/' '$dest_dir/'" 
                else
                    rot "ssh -t $dest_ssh_args $dest_ssh_port_arg mkdir -p '$dest_dir/'" 
                    rot mkdir -p "$local_dump_path/" 
                    rot "rsync -rlzvP $flags $src_scp_port_arg '$src_ssh_args$src_sep$src_dir/' '$local_dump_path/'" 
                    rot "rsync -rlzvP $flags $dest_scp_port_arg '$local_dump_path/' '$dest_ssh_args$dest_sep$dest_dir/'" 
                    rot "rm -r '$local_dump_path/'$postfix" 
                fi
                #scp copy
                #rot "rsync -rlzvP $flags $src_scp_port_arg '$src_ssh_args$src_sep$src_dir/'$postfix $dest_scp_port_arg '$dest_ssh_args$dest_sep$dest_dir/'"
            else
                 printf "6 source $src_ssh_port_arg '$src_ssh_args$src_sep$src_dir/' does not exist or is empty scp not needed \n\n" 
            fi
        fi
  
#      if [[ "$test_status" = 1 ]]; then
#        test_args "$src_ssh_args" "$src_dir"
#        test_args "$dest_ssh_args" "$dest_dir"
#      fi
  
    fi
}


function scp_copy_file(){
    local src_sep=":"
    local dest_sep=":"
    local src_ssh_args="$1"
    local src_file="$2"
    local dest_ssh_args="$3"
    local dest_file="$4"
    local flags="$5"
    local src_ssh_port="$6"
    local dest_ssh_port="$7"
    
  
    if [[ -z "$src_ssh_args" ]]; then
      local src_sep=""
      local src_is_local=true
    else
      local src_is_local=false
    fi
  
    if [[ -z "$dest_ssh_args" ]]; then
      local dest_sep=""
      local dest_is_local=true
    else
      local dest_is_local=false
    fi
   
    if [[ -n "$src_ssh_args" ]] && [[ -n "$dest_ssh_args" ]] && [[ "$src_ssh_args" = "$dest_ssh_args" ]]; then
      #working on same server with same login
  #rot "ssh -t $src_ssh_args scp -r '$src_file '$dest_file/'"
      #this tests 1 if the source exists, 2 if there is anything in the source directory
      if $(ssh $src_ssh_args '[[ -e '$src_file' ]]' 2>/dev/null); then
          rot "ssh -t $src_ssh_args mkdir -p '$dest_file' && scp -r '$src_file '$dest_file'"
      else
          printf "1 $src_ssh_args:$src_file does not exist, scp not needed to run \n\n" 
      fi
    else
      if $src_is_local; then    
        if [[ -e "$src_file" ]]; then    
          if $dest_is_local; then
            rot mkdir -p `dirname "$dest_file"`
          else
            rot "ssh -t $dest_ssh_args mkdir -p `dirname \"$dest_file\"`"
          fi
          rot "scp -3v $flags '$src_ssh_args$src_sep$src_file '$dest_ssh_args$dest_sep$dest_file'"
        else
          printf "2 source $src_file does not exist or is empty, scp not needed \n\n"
        fi 
      else
        if $(ssh $src_ssh_args '[[ -e '$src_file' ]]' 2>/dev/null); then    
          if $dest_is_local; then
              rot mkdir -p `dirname "$dest_file"`
          else
              rot "ssh -t $dest_ssh_args mkdir -p `dirname \"$dest_file\"`"
          fi
          rot "scp -3v $flags '$src_ssh_args$src_sep$src_file '$dest_ssh_args$dest_sep$dest_file'"
        else
            printf "3 source '$src_ssh_args$src_sep$src_file' does not exist or is empty scp not needed \n\n"
        fi
      fi
  
      if [[ "$test_status" = 1 ]]; then
        test_args "$src_ssh_args" "$src_file"
        test_args "$dest_ssh_args" "$dest_file"
      fi
    fi
}

function mysqldbcompare_dbs(){
  local server1=$1
  local server2=$2
  local dbs=$3
  local args=$4
  local dump=$5
  rot "mysqldbcompare --server1=\"$server1\" --server2=\"$server2\" $dbs $args > $dump"
}

function copy_db(){
    local src_path=$1
    local dest_path=$2
    local wp_prefix=$3
    local src_ssh_args=$4
    local dest_ssh_args=$5
    local src_port=$6
    local dest_port=$7
    local src_mysql_args=$8
    local dest_mysql_args=$9
    local local_database_dir=${10}

    #dump source db    
    dumpdb "$src_ssh_args" "$src_mysql_args $sei $src_db" "$src_path/$dump_name" "$src_port"
    scp_copy "$src_ssh_args" "$src_path" "$dest_ssh_args" "$dest_path" "" "$dump_name" "$src_port" "$dest_port" "$local_database_dir"  
    #make backup of destination db
    dumpdb "$dest_ssh_args" "$dest_mysql_args $sei $dest_db" "$dest_path/backup_of_database_you_dropped.sql" "$dest_port"
    #remove destination database 
    delete_and_create_db "$dest_ssh_args" "$dest_mysql_args" "$dest_db" "$dest_port"
    #put dump file into destination database
    restoredb "$dest_ssh_args" "$dest_mysql_args $dest_db" "$dest_path/$dump_name" "$dest_port"
    #change url in destination database 
    url_change "$dest_ssh_args" "$dest_url" "$dest_mysql_args $dest_db" "$wp_prefix" "$dest_port"
}

function git_pull(){
    local branch=$1
    local path=$2
    local remote_args=$3
    local port=$4

    if [ -z "$branch" ]; then
        printf "WARNING: you did not set a branch in your vars.sh \n"
        if [ "$dest" == "dev" ]; then
            local branch='develop'
            printf "WARNING: dev branch being set to '$branch' \n\n"
        elif [ "$dest" == "stage" ]; then
            local branch='release'
            printf "WARNING: stage branch being set to '$branch' \n\n"
        elif [ "$dest" == "prod" ]; then
            local branch='master'
            printf "WARNING: prod branch being set to '$branch' \n\n"
        fi
    fi
 
    if [[ -n $port ]]; then
        local port_arg=" -p $port"    
    else
        local port_arg=""    
    fi 
 
    if [ -z "$remote_args" ]; then
        local cmnd="cd '$path' && git fetch origin $branch && git reset --hard FETCH_HEAD" 
    else
        local cmnd="ssh -t $remote_args$port_arg 'cd '$path' && git fetch origin $branch && git reset --hard FETCH_HEAD'"
    fi
  
    rot "$cmnd" 
}

#function setVars(){
#    local vars=("${!1}")   
#    local remote_vars="${vars[0]}" 
#    local remote_vars2="${vars[1]}" 
#    local local_vars="${vars[2]}" 
#    printf "WARNING SETTING VARS: \n\n"
#    
#    declare -A conf_in # init array
#    config_in=( # set default values in config array
#        'WP_PREFIX'
#        'DB_NAME'
#        'DB_USER'
#        'DB_PASSWORD'
#        'HOST_SQL'
#        'USER_SSH'
#        'HOST_SSH'
#        'FULL_PATH'
#        'BRANCH'
#        'URL'
#    )
#    
#    declare -A config # init array
#    config=( # set default values in config array
#        [WP_PREFIX,desc]='#wp table prefix'
#        [WP_PREFIX]=''
#        [DB_NAME,desc]='#database name:'
#        [DB_NAME]=''
#        [DB_USER,desc]='#database user:'
#        [DB_USER]=''
#        [DB_PASSWORD,desc]='#database password'
#        [DB_PASSWORD]=''
#        [HOST_SQL,desc]='#host for SQL:'
#        [HOST_SQL]=''
#        [USER_SSH,desc]='#ssh username:'
#        [USER_SSH]=''
#        [HOST_SSH,desc]='#production host for SSH:'
#        [HOST_SSH]=''
#        [FULL_PATH,desc]='#full path:'
#        [FULL_PATH]=''
#        [BRANCH,desc]='#name of branch pull down:'
#        [BRANCH]=''
#        [URL,desc]='#url:'
#        [URL]=''
#    )
#  
#    if [ -e $remote_vars ]; then
#      while read line
#      do
#          if echo $line | grep -F = &>/dev/null
#          then
#              local varname=$(echo "$line" | cut -d '=' -f 1)
#              config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
#          fi
#      done < $remote_vars
#    fi  
#  
#    if [ -e $local_vars ]; then
#      while read line
#      do
#          if echo $line | grep -F = &>/dev/null
#          then
#              local varname=$(echo "$line" | cut -d '=' -f 1)
#              config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
#          fi
#      done < $local_vars
#    fi  
#    
#    for i in "${config_in[@]}"
#    do
#      if [ -z "${config[$i]// }" ]; then
#        printf "$i is unset, set it please \n"
#        printf "${config[$i,desc]}\n"
#        read input_var 
#        config[$i]="$input_var"
#      fi  
#    done
#  
#    printf "#!/bin/bash\n" 
#    printf "#BEGINNING OF $local_vars :)\n\n"
#    for i in "${config_in[@]}"
#    do
#      printf "${config[$i,desc]}\n"
#      printf "$i=${config[$i]}\n\n"
#    done
#  
#    function write_header(){
#      file_path=$1
#      printf "" > $file_path
#      printf "#!/bin/bash\n" >> $file_path
#      printf "#BEGINNING OF $(basename \"$file_path\") :) \n\n" >> $file_path
#    }
#  
#  
#    function write_to_vars(){
#        local remote_vars=$1
#        local remote_vars2=$2
#        local local_vars=$3
#        write_header "$local_vars"
#        write_header "$remote_vars"
#        write_header "$remote_vars2"
#        for i in "${config_in[@]}"
#        do  
#            local temp="${config[$i]}"
#            temp="${temp%\"}"
#            temp="${temp#\"}"      
#            temp="${temp#\'}"      
#            temp="${temp%\'}"
#            if [[ "$i" == *2 ]]; then
#                printf "${config[$i,desc]}\n" >> "$remote_vars2"
#                printf "$i=\"$temp\"\n\n" >> "$remote_vars2"
#            else
#                if [[ $i == DEV* ]]; then
#                    printf "${config[$i,desc]}\n" >> $local_vars
#                    printf "$i=\"$temp\"\n\n" >> $local_vars
#                else
#                    printf "${config[$i,desc]}\n" >> $remote_vars
#                    printf "$i=\"$temp\"\n\n" >> $remote_vars
#                fi
#            fi 
#        done
#    }
#    printf "Are you sure you want to overwrite your\n $local_vars \n and \n$remote_vars\n files with this?  [y/N]\n" 
#    read -r response
#    local response=${response,,}    # tolower
#    if [[ $response =~ ^(yes|y)$ ]]; then 
#        write_to_vars "$remote_vars" "$remote_vars2" "$local_vars" 
#        printf "Aren't you smart, you just wrote your vars files :) \n\n"
#    fi
#}


function setVarsFile(){
    local filename=`basename ${1%/}`
    local site_dir="$2"
    if [ -e "$filename" ]; then
        path="$site_dir/$filename"
    fi
    printf "WARNING SETTING VARS OF: \n $path \n\n"
    
    declare -A conf_in # init array
    config_in=( # set default values in config array
        'WP_PREFIX'
        'DB_NAME'
        'DB_USER'
        'DB_PASSWORD'
        'HOST_SQL'
        'USER_SSH'
        'USER_SSH_PORT'
        'HOST_SSH'
        'FULL_PATH'
        'BRANCH'
        'URL'
    )
    
    declare -A config # init array
    config=( # set default values in config array
        [WP_PREFIX,desc]='#wp table prefix'
        [WP_PREFIX]=''
        [DB_NAME,desc]='#database name:'
        [DB_NAME]=''
        [DB_USER,desc]='#database user:'
        [DB_USER]=''
        [DB_PASSWORD,desc]='#database password'
        [DB_PASSWORD]=''
        [HOST_SQL,desc]='#host for SQL (usually localhost):'
        [HOST_SQL]=''
        [USER_SSH,desc]='#server ssh username:'
        [USER_SSH]=''
        [USER_SSH_PORT,desc]='#server ssh port:'
        [USER_SSH_PORT]=''
        [HOST_SSH,desc]='#production host for SSH:'
        [HOST_SSH]=''
        [FULL_PATH,desc]='#full path:'
        [FULL_PATH]=''
        [BRANCH,desc]='#name of branch pull down:'
        [BRANCH]=''
        [URL,desc]='#url:'
        [URL]=''
    )
  
    if [ -e $path ]; then
      while read line
      do
          if echo $line | grep -F = &>/dev/null
          then
              local varname=$(echo "$line" | cut -d '=' -f 1)
              config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
          fi
      done < $path
    fi  
  
    for i in "${config_in[@]}"
    do
      if [ -z "${config[$i]// }" ]; then
        printf "$i is unset, set it please \n"
        printf "${config[$i,desc]}\n"
        read input_var 
        config[$i]="$input_var"
      fi  
    done
  
    printf "#!/bin/bash\n" 
    printf "#BEGINNING OF $vars :)\n\n"
    for i in "${config_in[@]}"
    do
      printf "${config[$i,desc]}\n"
      printf "$i=${config[$i]}\n\n"
    done
  
    function write_header(){
      file_path=$1
      printf "" > $file_path
      printf "#!/bin/bash\n" >> $file_path
      printf "#BEGINNING OF $(basename \"$file_path\") :) \n\n" >> $file_path
    }
  
    function write_to_vars(){
        local vars=$1
        write_header "$vars"
        for i in "${config_in[@]}"
        do  
            local temp="${config[$i]}"
            temp="${temp%\"}"
            temp="${temp#\"}"      
            temp="${temp#\'}"      
            temp="${temp%\'}"
            printf "${config[$i,desc]}\n" >> "$vars"
            printf "$i=\"$temp\"\n\n" >> "$vars"
        done
    }

    printf "Are you sure you want to overwrite your\n $vars files with this?  [y/N]\n" 
    read -r response
    local response=${response,,}    # tolower
    if [[ $response =~ ^(yes|y)$ ]]; then 
        write_to_vars "$vars" 
        printf "Aren't you smart, you just wrote your vars files :) \n\n"
    fi
}

makeWordpressPath(){
    local site_path=$1
    rot mkdir -p \"$site_path\"
    rot cd \"$site_path\" 
    rot wget https://wordpress.org/latest.tar.gz
    rot tar -xzvf latest.tar.gz 
    rot cp -rf wordpress/. .
    rot rm -rf wordpress
    rot rm latest.tar.gz
}

makeWordpress(){
    local ssh_args=$1
    local site_path=$2
    if [[ -z "$ssh_args" ]]; then
        makeWordpressPath "$site_path"
    else
        rot ssh "$ssh_args" "$(typeset -f); makeWordpressPath '$site_path'"
    fi
}

makeWpConfig(){
printf "
<?php

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to \"wp-config.php\" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'database_name_here');

/** MySQL database username */
define('DB_USER', 'username_here');

/** MySQL database password */
define('DB_PASSWORD', 'password_here');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
/** Disable editing from Dashboard. 
Placing this line in wp-config.php is equivalent to removing the 'edit_themes', 'edit_plugins' and 'edit_files' capabilities of all users:
*/
define('DISALLOW_FILE_EDIT', true);
" > wp-config.php
}



hardenWpConfig(){
    local site_path=$1
    if [[ "$location" = DEV ]]; then
        rot chmod 404 \"$site_path/wp-config.php\"
    else
        rot chmod 400 \"$site_path/wp-config.php\"
    fi 
}


makeConfigPath(){
    local site_path=$1
    local database=$2
    local username=$3
    local password=$4

    rot cd \"$site_path\"

    if [[ -e 'wp-config-sample.php' ]]; then
        if [[ -e 'wp-config.php' ]]; then
           rot chmod +w \"wp-config.php\" 
        fi
        
        rot cp wp-config-sample.php wp-config.php
printf "/** Disable editing from Dashboard. 
Placing this line in wp-config.php is equivalent to removing the 'edit_themes', 'edit_plugins' and 'edit_files' capabilities of all users:
*/
define('DISALLOW_FILE_EDIT', true);" >> wp-config.php
    else
        rot makeWpConfig
    fi
    hardenWpConfig "$site_path"

    rot replace 'database_name_here' "$database" -- wp-config.php
    rot replace 'username_here' "$username" -- wp-config.php    
    rot replace 'password_here' "$password" -- wp-config.php

    if [[ "$run_status" == 1 ]]; then
        find . -name wp-config.php -print | while read line
        do
          printf "$line\n"
          SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt)
          STRING='put your unique phrase here'
          printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s $line
        done
    else
        rot 'find . -name wp-config.php -print | while read line
        do
          printf "$line\n"
          SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt)
          STRING='put your unique phrase here'
          printf '%s\n' \"g/$STRING/d\" a \"$SALT\" . w | ed -s $line
        done'
    fi
}

makeConfig(){
    local ssh_args=$1
    local site_path=$2
    local database=$3
    local username=$4
    local password=$5

    if [[ -z "$ssh_args" ]]; then
        makeConfigPath "$site_path" "$database" "$username" "$password"
    else
        rot ssh \"$ssh_args\" \"$(typeset -f); makeConfigPath '$site_path' '$database' '$username' '$password'\"
    fi
}

writeHtaccess(){
    local site_path=$1   
    local ht_path="$site_path/.htaccess"
    local folder_name=$2   
    
    if [[ $run_status = 1 ]]; then    
printf "
<files wp-config.php>
order allow,deny
deny from all
</files>

# Block the include-only files.
<IfModule mod_rewrite.c>
RewriteEngine On
" > $ht_path
        if [[ "$folder_name" = "/" ]] || [[  "$folder_name" = "" ]] ; then
            printf "RewriteBase /" >> $ht_path
        else
            printf "RewriteBase /$folder_name/" >> $ht_path
        fi 
printf "
RewriteRule ^wp-admin/includes/ - [F,L]
RewriteRule !^wp-includes/ - [S=3]
RewriteRule ^wp-includes/[^/]+\.php$ - [F,L]
RewriteRule ^wp-includes/js/tinymce/langs/.+\.php - [F,L]
RewriteRule ^wp-includes/theme-compat/ - [F,L]
</IfModule>" >> $ht_path
    else
printf "this would be written to .htaccess:\n"
printf "
<files wp-config.php>
order allow,deny
deny from all
</files>

# Block the include-only files.
<IfModule mod_rewrite.c>
RewriteEngine On
"
        if [[ "$folder_name" = "/" ]] || [[  "$folder_name" = "" ]] ; then
            printf "RewriteBase /"
        else
            printf "RewriteBase /$folder_name/"
        fi 
printf "
RewriteRule ^wp-admin/includes/ - [F,L]
RewriteRule !^wp-includes/ - [S=3]
RewriteRule ^wp-includes/[^/]+\.php$ - [F,L]
RewriteRule ^wp-includes/js/tinymce/langs/.+\.php - [F,L]
RewriteRule ^wp-includes/theme-compat/ - [F,L]
</IfModule>"
    fi 
}

makeWordpressPath(){
    local site_path=$1
    rot mkdir -p \"$site_path\"
    rot cd \"$site_path\" 
    rot wget https://wordpress.org/latest.tar.gz
    rot tar -xzf latest.tar.gz 
    rot cp -rf wordpress/. .
    rot rm -rf wordpress
    rot rm latest.tar.gz
}

hardenWordpress(){
    local site_path=$1
    rot find \"$site_path\" ! -name '.htaccess' ! -name 'wp-config.php' -type f -exec chmod 644 {} \;
    rot find \"$site_path\" -type d -exec chmod 755 {} \;
}

makeWordpress(){
    local ssh_args=$1
    local site_path=$2
    if [[ -z "$ssh_args" ]]; then
        makeWordpressPath "$site_path"
    else
        rot ssh "$ssh_args" "$(typeset -f); makeWordpressPath '$site_path'"
    fi
    
}

function moveFileFromData(){
    local local_path=$1
    local dest_ssh_args=$2
    local site_path=$3
    if [[ -n "$dest_ssh_args" ]]; then
        scp_copy_file "" "$local_path" "$dest_ssh_args" "$site_path" "" "$file_name"
    else 
        cp "$local_path" "$site_path"
    fi 
}

makeHtaccess(){
    local ssh_args=$1
    local site_path=$2
    local folder_name=$3
    if [[ -z "$ssh_args" ]]; then
        writeHtaccess "$site_path" "$folder_name"
    else
        rot ssh "$ssh_args" "$(typeset -f); writeHtaccess '$site_path' '$folder_name'"
    fi
}

hardenHtaccess(){
    local site_path=$1
    rot chmod 604 \"$site_path/.htaccess\"
}

function makeOrMoveHtaccess(){
    local dest_ssh_args=$1
    local site_path=$2
    local current_site_path=$3
    local location=$4
    local dest_ssh_args=$5
    local src_path=$6
    local folder_name=$7 

    if [[ -e "$current_site_path/$location/.htaccess" ]]; then
        moveFileFromData "$current_site_path/$location/.htaccess" "$src_ssh_args" "$src_path" 
    elif [[ -e "$current_site_path/.htaccess" ]]; then
        moveFileFromData "$current_site_path/.htaccess" "$src_ssh_args" "$src_path" 
    else  
        if [[ -z $folder_name ]]; then
            if [[ "$location" = prod* ]]; then
                local folder_name=""  
                makeHtaccess "$src_ssh_args" "$src_path" "$folder_name"
            else
                local folder_name="$(basename "$src_path")"
                makeHtaccess "$src_ssh_args" "$src_path" "$folder_name" 
            fi
        else 
            echo "makeHtaccess $src_ssh_args $src_path $folder_name"
            makeHtaccess "$src_ssh_args" "$src_path" "$folder_name"
        fi
    fi
    hardenHtaccess "$site_path" 
}


function makeGitPath(){
    local site_path=$1
    local git_url=$2
    cd "$site_path"
    rot git init
    rot git remote add origin "$git_url" 
}

function makeGit(){
    local ssh_args=$1
    local site_path=$2
    local git_url=$3
    if [[ -z "$ssh_args" ]]; then
        makeGitPath "$site_path" "$git_url"
    else
        rot ssh "$ssh_args" "$(typeset -f); makeGitPath '$site_path' '$git_url'"
    fi
}

function makeGitMain(){
    repo_name=$1
    if [[ "$run_status" == 1 ]]; then
        curl -X POST -v -u viridiantechnologies:viridsomtech -H "Content-Type: application/json"   https://api.bitbucket.org/2.0/repositories/viridiantech/"$repo_name" -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'
    else 
        rot curl -X POST -v -u viridiantechnologies:viridsomtech -H "Content-Type: application/json"   https://api.bitbucket.org/2.0/repositories/viridiantech/"$repo_name" -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'
    fi 
}

function getFileNames(){    
    local __resultvar=$1
    local paths=("${!2}") 
    local names=()

    for i in "${paths[@]}"; do
        names+=( $(basename "$i") )        
    done   

    eval $__resultvar="('${names[@]}')" 
}

function getLocationNames(){    
    local __resultvar=$1
    local paths=("${!2}") 
    local names=()

    for i in "${paths[@]}"; do
        i=$(basename "$i") 
        names+=("${i%.*}")        
    done   

#    for i in "${names[@]}"; do
#        echo "name: $i"
#    done 
    eval $__resultvar+="('${names[@]}')" 
}


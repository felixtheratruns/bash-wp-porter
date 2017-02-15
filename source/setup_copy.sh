#!/usr/bin/env bash

#    This file is part of "Porter." (written in bash).
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
#    along with  Porter.  If not, see <http://www.gnu.org/licenses/>.

# If there are input files (for example) that follow the options, they
# will remain in the "$@" positional parameters.

#arguments:
#1 "actions source destination"
#2 "script directory path"
#3 "sites directory name"
#4 "remote variables file name"
#5 "base variables file path"
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
    local current_site_path="$script_dir/$sites_directory/$current_site"
    local local_uploads_path="$local_dump_path/uploads"
    mkdir -p "$local_uploads_path"
    if [[ $local_uploads_path == *uploads ]] && [[ -e "$local_uploads_path/"* ]]; then
        rm -rf "$local_uploads_path/"* 
    fi

    #sourceVars "$base_vars_path"
   
    setActionOpts(){
      options=$1
      src=$2
      dest=$3
    }
    
    setActionOpts $action_arguments
    
    #make script exit on error
    #trap 'abort 0' 0 
    #set -e 
    
    printf "argument order: \n";
    printf "options: $options \n";
    printf "src: $src \n";
    printf "dest: $dest \n";
    printf "run: $run \n\n";
    
    IFS=',' read -a opt_arr <<< $options
     
    
#    if $(isInOpts "opt_arr[@]" 'setvars'); then
#      printf "setvars is in opts \n\n"
#      setVars "site_vars_array[@]"
#    fi
    
    #  echo "$script_dir/$sites_directory/$remote_vars_name"
    #  echo "$script_dir/$sites_directory/$remote_vars_name""
    for i in "${site_vars_array[@]}" 
    do 
      test_encrypt "$i"
    done 
  
  #  test_encrypt "$_local_vars_path"
    
    if [ $# -eq 0 ]; then
      printusage
    fi
    
    if [[ -z $options ]]; then
      printf "YOU HAVE SPECIFIED NO OPTIONS\n\n"
      abort 1;
    fi
    
    if [[ -z $src ]]; then
      printf "YOU HAVE SPECIFIED NO SOURCE SERVER\n\n"
      abort 1;
    fi
    
    if [[ -z $dest ]]; then
      printf "YOU HAVE SPECIFIED NO DESTINATION SERVER\n\n"
      abort 1;
    fi
    
    if [[ "$src" == "$dest"  ]]; then
      printf "WARNING: Your source and destination are the same:\n"
      printf "source: $src \n"
      printf "destination: $dest \n"
    fi
    
    if [[ "$run_status" == 1 ]]; then
      printf "RUNNING, CURRENT SITE: $current_site\n\n"
    else
      printf "TESTING, CURRENT SITE: $current_site\n\n"
    fi
    
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
            if [[ $src_ssh_port ]]; then
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
            if [[ -n "$src_ssh_args" ]]; then
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

    getSetupDest(){
        local loc=$1
#       for moo in ${locations[@]}; do
#           echo "before: $moo"
#       done
        getLocationNames locations "site_vars_array[@]" 
        if $(isInOpts "locations[@]" "$loc" ); then
            printf "loc: $loc"
            sourceFileWithName "site_vars_array[@]" "$loc"
            setLocationVariables  
            dest_ssh_port=$ssh_port

            if [[ $dest_ssh_port ]]; then
                dest_ssh_args="$ssh_args -p $dest_ssh_port"
            else
                dest_ssh_args="$ssh_args"
            fi 
 
            dest_ssh_args="$ssh_args -p $dest_ssh_port"
            dest_scp_args="$ssh_args"
            dest_branch="$branch"
            dest_comparedb="$comparedb"
            dest_url=$url
            dest_mysql_args=$mysql_args
            dest_mysql_args_nh=$mysql_args_nh
            dest_db=$db
            dest_path=$path

            if [[ -n "$dest_ssh_args" ]]; then
                local tmp=$(ssh -t $dest_ssh_args "pwd && mkdir -p '$db_folder'" 2>/dev/null)
                #local tmp=$(ssh -t $dest_ssh_args pwd 2>/dev/null)
                tmp=${tmp//[^a-zA-Z0-9_:\.\/\-]/}
                dest_dump_path="$tmp/$db_folder"
            else
                dest_dump_path="$local_dump_path"
            fi 
            dest_uploads_path=$uploads_path

        else
            printf "Not a valid option for source: '$dest'"
            abort 1
        fi
    } 

    getSetupSrc "$src"
    getSetupDest "$dest"

    if $(isInOpts "opt_arr[@]" 'all'); then
        printf "all is in opts \n\n"
        scp_copy "$src_scp_args" "$src_uploads_path" "$dest_scp_args" "$dest_uploads_path" "-r" "*" "$src_ssh_port" "$dest_ssh_port" "$local_uploads_path"
        #copy_db "$src_dump_path" "$dest_dump_path" "$wp_prefix" "$src_scp_args" "$dest_scp_args" "$src_ssh_port" "$dest_ssh_port" "$src_mysql_args" "$dest_mysql_args" "$local_dump_path"
        copy_db "$src_dump_path" "$dest_dump_path" "$wp_prefix" "$src_scp_args" "$dest_scp_args" "$src_ssh_port" "$dest_ssh_port" "$src_mysql_args" "$dest_mysql_args" "$local_dump_path"
        git_pull "$dest_branch" "$dest_path" "$dest_ssh_args"  
    fi
   
 
    if $(isInOpts "opt_arr[@]" 'db'); then
        printf "db is in opts \n\n"
        #copy_db "$src_dump_path" "$dest_dump_path" "$wp_prefix" "$src_scp_args" "$dest_scp_args" "$src_ssh_port" "$dest_ssh_port" "$src_mysql_args" "$dest_mysql_args"
        copy_db "$src_dump_path" "$dest_dump_path" "$wp_prefix" "$src_scp_args" "$dest_scp_args" "$src_ssh_port" "$dest_ssh_port" "$src_mysql_args" "$dest_mysql_args" "$local_dump_path"
    fi
    
    if $(isInOpts "opt_arr[@]" 'up'); then
        printf "up is in opts \n\n"
        scp_copy "$src_scp_args" "$src_uploads_path" "$dest_scp_args" "$dest_uploads_path" "-r" "*" "$src_ssh_port" "$dest_ssh_port" "$local_uploads_path"
    fi
    
    if $(isInOpts "opt_arr[@]" 'updb'); then
        printf "updb is in opts \n\n"
        scp_copy "$src_scp_args" "$src_uploads_path" "$dest_scp_args" "$dest_uploads_path" "-r" "*" "$src_ssh_port" "$dest_ssh_port" "$local_uploads_path"
        copy_db "$src_dump_path" "$dest_dump_path" "$wp_prefix" "$src_scp_args" "$dest_scp_args" "$src_ssh_port" "$dest_ssh_port" "$src_mysql_args" "$dest_mysql_args" "$local_dump_path"
    fi
    
    if $(isInOpts "opt_arr[@]" 'git'); then
        printf "git is in opts \n\n"
        #printf "$dest_path \n"
        #printf "$dest_ssh_args \n"
        git_pull "$dest_branch" "$dest_path" "$dest_ssh_args"  
    fi
    
    if $(isInOpts "opt_arr[@]" 'dumpdb'); then
        printf "dumpdb is in opts \n\n"
        dumpdb "$src_ssh_args" "$src_mysql_args_nh $sei $src_db" "$src_dump_path/dump_skip_extended_insert.sql" "$src_ssh_port" 
        dumpdb "$src_ssh_args" "$src_mysql_args_nh $no_data $src_db" "$src_dump_path/dump_no_data.sql" "$src_ssh_port" 
        dumpdb "$src_ssh_args" "$src_mysql_args_nh $no_create_tables $src_db" "$src_dump_path/dump_no_create_tables.sql" "$src_ssh_port" 
    fi
    
    if $(isInOpts "opt_arr[@]" 'mysqldbcompare'); then
        printf "mysqldbcompare is in opts \n\n"
        mysqldbcompare_dbs "$src_comparedb" "$dest_comparedb" "$compare_db_name:$DB_NAME" "--changes-for=server1 --difftype=sql --run-all-tests" "compare_$dump_name"
    fi
}

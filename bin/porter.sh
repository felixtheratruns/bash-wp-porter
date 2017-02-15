#!/usr/bin/env bash

#    This file is part of Porter.
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




trap "exit" INT
trap 'abort $ERR' ERR 
set -e

tmp="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
tmp=`dirname "$tmp"`
tmp=`dirname "$tmp"`
exec >  >(tee -a $tmp/webadmin.log)
exec 2> >(tee -a $tmp/webadmin.log >&2)
printf "script start: `date +%Y-%m-%d:%H:%M:%S`\n\n"

if [ "$(id -u)" == "0" ]; then
   echo "WARNING YOU ARE RUNNING THIS AS ROOT\n\n" 1>&2
fi
#variables with directories always end without a /
#if the variable is created by the user in vars.sh then I remove any / before using it in variables I create
#directories are specified by the variable name not the trailing / (as there will be no /):w

#if you have a SSH key with access to the destination server and the source server does not, adding -o "ForwardAgent=yes" 
#will allow you to forward your SSH agent to the source server so that it can use your SSH key to connect to the destination server.

_source_dir='source'
_bin_dir='bin'


#global variables set in script:
#tmp="`readlink -f "$0"`"
tmp="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
#get base path of script
tmp=`dirname "$tmp"`
_script_dir=`dirname "$tmp"`
_base_vars="base_vars.sh"
_remote_vars_name="remote_vars.sh"
_remote_vars_name2="remote_vars2.sh"
_site_vars="site_vars.sh"
#these are just remote vars, the local vars get sourced later:
_vars_names=("$_remote_vars_name" "$_remote_vars_name2" "site_vars.sh")
_sites_directory="sites"
_base_vars_path="$_script_dir/$_base_vars"
#source "$_base_vars_path"
#_remote_vars_path="$_script_dir/$_sites_directory/$_remote_vars_name"
#_local_vars_path="$_script_dir/$_sites_directory/$_local_vars_name"
#echo "_remote_vars_path: $_remote_vars_path"
#echo "_local_vars_path: $_local_vars_path"

bash_oo_framework="$_script_dir/$_source_dir/bash-oo-framework/lib/oo-bootstrap.sh"
#source "$bash_oo_framework"
#import util/log util/exception util/tryCatch util/namedParameters util/class

#get general functions and encryption functions
actions_path="$_script_dir/$_source_dir/actions.sh"
funct_path="$_script_dir/$_source_dir/funct.sh"
encrypt_path="$_script_dir/$_source_dir/encrypt.sh"
setup_path="$_script_dir/$_source_dir/setup.sh"
source "$actions_path"
source "$funct_path"
source "$encrypt_path"
source "$setup_path"

# Usage info
showHelp() {
sourceVars $_base_vars_path
echo "CURRENT SITE: $current_site"
cat << EOF
Usage: ${0##*/}...
    -a, --action "[actions] [source] [destination]"
        actions are seperated by commas: ,
        e.g. porter.sh -a "db,up stage dev"
        e.g. porter.sh -a "all stage dev"
        e.g. porter.sh -a "updb prod stage"
    -c, --create "[actions] [locations]"
        performs the actions on the following locations
        if it is the git_main action it will only 
        create the main repository once
        operations:
        1 'db' create database (install wordpress? no)
        2 'git' create git repo at location
        3 'git_main' create main git repo
        4 'ht' make .htaccess
        5 'robots' robots.txt
        6 'config' wp-config.php
        7 'wp' wordpress files
        8 'files' all files 4-7
        9 'all' except git_main
        10 'new' all and git_main 
    -e, --encrypt "site"
        encrypt the .sh files you have put in the site directory  
    -h, --help 
        displays this help info and exits
    -n, --setvars 
        sets local and remote vars from any properly named files you have 
        in the current site's folder
    -p, --path 
        puts the script in your path 
    -r, --run 
        runs commands rather than just displaying them
    -s, --set
        sets the script to use a certain site
    -t, --test 
        runs tests
    -v, --verbose  verbose mode.
    -w, --showpass show password on command line
EOF
}


# Reset all variables that might be set
verbose=0 # Variables to be evaluated as shell arithmetic should be initialized to a default or validated beforehand.
showpass=0 #Variables to be evaluated as shell arithmetic should be initialized to a default or validated beforehand.
output_file=""
verbose=0
test_status=0
_run_status=0

#change long format arguments (-- and then a long name) to short format (- and then a single letter) and puts result in $parsed_args
function parse_args()
{
    m_parsed_args=("$@")
    #changes long format arguments (--looong) to short format (-l) by doing this:
    #res=${res/--looong/-l}
    for ((i = 0; i < $#; i++)); do
        m_parsed_args[i]="${m_parsed_args[i]/--action/-a}"
        m_parsed_args[i]="${m_parsed_args[i]/--create/-c}"
        m_parsed_args[i]="${m_parsed_args[i]/--encrypt/-e}"
        m_parsed_args[i]="${m_parsed_args[i]/--help/-h}"
        m_parsed_args[i]="${m_parsed_args[i]/--setvars/-n}"
        m_parsed_args[i]="${m_parsed_args[i]/--path/-p}"
        m_parsed_args[i]="${m_parsed_args[i]/--run/-r}"
        m_parsed_args[i]="${m_parsed_args[i]/--set/-s}"
        m_parsed_args[i]="${m_parsed_args[i]/--test/-t}"
        m_parsed_args[i]="${m_parsed_args[i]/--verbose/-v}"
        m_parsed_args[i]="${m_parsed_args[i]/--showpass/-w}"
    done
}
#extracts arguments into the script's variables

#we will source vars before every argument that needs vars sourced
function handle_args()
{
  echo "in handle_args()"
  echo $1
  echo $2
  echo $3
  while getopts "a:c:e:hn:prs:tvw" opt; do
    case $opt in
      a)
        var_arr=()
        action_arguments="$OPTARG"
        prepareVars _vars_names "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path"
        makeVarArr var_arr "$_script_dir" "$_sites_directory" "$current_site" "_vars_names[@]" 
        doActions "$action_arguments" "$_script_dir" "$_sites_directory" "$_base_vars_path" "var_arr[@]" "$current_site" "$_run_status" 
        abort 0
        ;;
      c)
        var_arr=()
        action_arguments="$OPTARG"
        prepareVars _vars_names "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path"
        makeVarArr var_arr "$_script_dir" "$_sites_directory" "$current_site" "_vars_names[@]"
        #folder name will be populated by the source file 
        #got rid of $folder_name but need to implement way to copy ht access from site folder
        doSetup "$action_arguments" "$_script_dir" "$_sites_directory" "$_base_vars_path" "var_arr[@]" "$current_site" "$_run_status"
        abort 0
        ;;
      e)
        var_arr=()
        #local site_name=`basename $OPTARG`
        #prepareVars 
        prepareVars _vars_names "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path" "$OPTARG"
        makeVarArr var_arr "$_script_dir" "$_sites_directory" "$current_site" "_vars_names[@]" 
        #path to site, array of vars, _run_status
        encryptSiteVars "`getPathToSite $OPTARG`" "var_arr[@]"
        ;;
      h)# Call a "showHelp" function to display a synopsis, then exit.
        showHelp
        abort 0
        ;;
      n) 
        #prepareVars _vars_names "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path" "$OPTARG"
        #makeVarArr var_arr "$_script_dir" "$_sites_directory" "$current_site" "_vars_names[@]" 
        setVarsFile "$OPTARG" "$_sites_directory" 
        abort 0
        ;;
      p) 
        #put script in path
        printf "adding \n export PATH=\$PATH:$_script_dir/$_bin_dir \nto bashrc\n\n"
        echo "export PATH=\$PATH:\"$_script_dir/$_bin_dir\"" >> ~/.bashrc
        # export PATH="$PATH:$_script_dir/$_bin_dir"
        # printf "PATH is now: $PATH\n\n"
        # exec /bin/bash
        abort 0
        ;;
      r) 
        _run_status=$((_run_status+1))
        ;;
      s)
        var_arr=()
        prepareVars _vars_names "$_script_dir" "$_sites_directory" "$_remote_vars_name" "$_base_vars_path"
        makeVarArr var_arr "$_script_dir" "$_sites_directory" "$current_site" "_vars_names[@]" "$OPTARG"
        setCurrentSite "$OPTARG" "$_script_dir" "$_sites_directory" "$_run_status" "$_base_vars_path" "$_remote_vars_name" "var_arr[@]"
        ;;
      t)# this option runs extra tests 
        test_status=$((test_status+1))
        ;;
      v)
        verbose=$((verbose + 1)) # Each -v argument adds 1 to verbosity.
        ;;
      w)
        showpass=1 
        ;;
      \?)
        echo "Invalid option: -$OPTARG"
        echo "For a list of options run the script with -h"
        abort 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        abort 1
        ;;
    esac
  done
}

parse_args "$@"
handle_args "${m_parsed_args[@]}"


if [[ "$run" == 'run' ]]; then
  printf "DONE RUNNING, CURRENT SITE: $current_site\n\n"
else
  printf "DONE TESTING, CURRENT SITE: $current_site\n\n"
fi
abort 0 

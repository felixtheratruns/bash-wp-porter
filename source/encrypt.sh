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
#    along with  Porter.  If not, see <http://www.gnu.org/licenses/>.


#function encrypt_all(){
#local dir_names=()
#for f in *; do
#  if [[ -d $f ]]; then
#    local dir=$(readlink -f $f)
#    local rv="$dir/remote_vars.sh"
#    local lv="$dir/vars.sh"
#    printf "$rv\n"
#    printf "$lv\n"
#    rm "$rv"
#    rm "$lv"
##    encrypt_ssl "$lv" "$lv.enc" "$pass"
#  fi
#done
#}
#echo "meow $_base_vars"
#echo " $_script_dir"
#echo " $_base_vars"
#echo " $_remote_var_name"
#echo " $_site_directory"

function encrypt_ssl(){
  local file_path=$1
  local en_file_path=$2
  local pass=$3
  if [ -e "$file_path" ]; then
    openssl enc -aes-256-cbc -salt -in "$file_path" -out "$en_file_path" -k "$pass"
    #rm "$file_path"
  else 
    printf "Did not encrypt $file_path\n"
    printf "as it doesn't exist\n\n"
  fi
#  history -c && history -w
}

function decrypt_ssl(){
  local file_path=$1
  local en_file_path=$2
  local pass=$3
  if [ -e "$en_file_path" ]; then
    openssl enc -aes-256-cbc -d -in "$en_file_path" -out "$file_path" -k "$pass"
  else  
    printf "Did not decrypt $en_file_path\n"
    printf "as it doesn't exist\n\n"
  fi
#  history -c && history -w
}

encryptOne(){
  local path=$1
  local pass=$2
  encrypt_ssl "$path" "$path.enc" "$pass"
}

encryptOnePathThenRest(){
  declare -a argArr=("${1}")
  echo "${argArr[@]}"
}

#paths of: 1 current site 2  vars 3 local vars
encryptSiteVars(){
    local current_site=$1
    local var_arr=("${!2}")  
    before_first_encrypt=true
    local pass=""
    for i in "${var_arr[@]}"; do
        if $before_first_encrypt && [ -e "$i" ]; then
            read -s  -p "Password:" pass
            encrypt_ssl "$i" "$i.enc" "$pass"
            before_first_encrypt=false
            #asks for confirmation with every additional file
        elif ! $before_first_encrypt && [ -e "$i" ]; then
            read -r -p "You have a $i, do you want encrypt that with the same password and overwrite your encrypted file with it?  [y/N]" response
            local response=${response,,}
            if [ $response = 'y' ] || [ $response = 'yes' ]; then
                encrypt_ssl "$i" "$i.enc" "$pass"
            fi
        fi    
    done
    abort 0
}
#fi

test_encrypt(){
    local vars=$1

    if [[ -e "$vars.enc"  ]]; then
        :
    else 
        printf "WARNING: you have no $current_site: $vars.enc \n\n"
    fi     
  

    if [ -e "$vars" ]; then
#        echo "sourcing $vars"
#        source "$vars"
        :
    else 
        printf "WARNING: you have no $current_site: $vars\n\n"
        if [[ -e "$vars.enc" ]]; then
            printf "Script will attempt to decrypt vars:\n"
            if [[ -z "$pass" ]]; then
              read -s  -p "Password:" pass
            fi
            printf "Decrypting...\n"
            decrypt_ssl "$vars" "$vars.enc" "$pass"
            printf "\n\n"
        else
            printf "Can't decrypt $vars.enc because it doesn't exist\n\n"
        fi 
    fi
}




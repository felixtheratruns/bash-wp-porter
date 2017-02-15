#!/bin/bash

function encrypt_ssl(){
  local file_path=$1
  local en_file_path=$2
  local pass=$3
  printf  "$file_path" -out "$en_file_path" -k "$pass"
  if [[ -e $file_path ]]; then
    openssl enc -aes-256-cbc -salt -in "$file_path" -out "$en_file_path" -k "$pass"
    #rm "$file_path"
  else
    printf "Did not encrypt $file_path\n"
    printf "as it doesn't exist\n\n"
  fi
#  history -c && history -w
}


function encrypt_all(){
  local pass=$1
  for f in *; do
    if [[ -d $f ]]; then
      local dir=$(readlink -f $f)
      local rv="$dir/remote_vars.sh"
      local lv="$dir/vars.sh"
      printf "Decrypting to:\n"
      printf "$rv\n"
      printf "$lv\n"
      encrypt_ssl "$lv" "$lv.enc" "$pass"
      encrypt_ssl "$rv" "$rv.enc" "$pass"
    fi
  done
}

printf "this will overwrite all your encrypted files!\n\n" 
read -s  -p "Password:" pass
encrypt_all $pass



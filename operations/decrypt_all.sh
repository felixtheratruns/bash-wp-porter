#!/bin/bash

function decrypt_ssl(){
  local file_path=$1
  local en_file_path=$2
  local pass=$3
  if [[ -e $en_file_path ]]; then
    openssl enc -aes-256-cbc -d -in "$en_file_path" -out "$file_path" -k "$pass"
  else
    printf "Did not decrypt $en_file_path\n"
    printf "as it doesn't exist\n\n"
  fi
#  history -c && history -w
}

function decrypt_all(){
  local pass=$1
  for f in *; do
    if [[ -d $f ]]; then
      local dir=$(readlink -f $f)
      local rv="$dir/remote_vars.sh"
      local lv="$dir/vars.sh"
      printf "Decrypting to:\n"
      printf "$rv\n"
      printf "$lv\n"
      decrypt_ssl "$lv" "$lv.enc" "$pass"
      decrypt_ssl "$rv" "$rv.enc" "$pass"
    fi
  done
}

printf "this will overwrite all your decrypted files!\n\n" 
read -s  -p "Password:" pass
decrypt_all $pass



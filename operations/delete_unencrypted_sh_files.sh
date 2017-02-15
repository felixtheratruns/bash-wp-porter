#!/bin/bash

function delete_all(){ 
  SAVEIFS=$IFS
  IFS=$(echo -en "\n\b")
  for f in *; do
    if [[ -d $f ]]; then
#        local dir=$(readlink -f $f)
#        local rv="$dir/*.sh"
#        local lv="$dir/vars.sh"
#        printf "DELETING:\n"
#        printf "$rv\n"
#        printf "$lv\n"
#      mv $f/vars.sh.enc $f/joel_vars.sh.enc
#      printf "$f/*.sh \n"
      
      for s in $(ls $f/*); do
        if [[ $s =~ .*\.sh$ ]]; then 
          printf "deleting: $s \n"
          rm "$s"
        fi
      done

#      rm "$rv"
#      rm "$lv"
    fi
  done
  IFS=$SAVEIFS
}

delete_all



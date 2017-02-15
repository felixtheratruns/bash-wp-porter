#This is like not even alpha
#Documentation is not finished
#See script output when given no arguments for a description of what it does
#Basic usage

To do all operations from stage.sh to dev.sh in sites/yourwebsite/:


porter.sh -r -a "all stage dev"

To do the same in test mode:

porter.sh -a "all stage dev"

To just copy the database:

porter.sh -r -a "db stage dev"

#Getting Started
make sure you have the newest version:
git pull origin master


##Put script in your path

###EXAMPLE 1 go to bash-wp-porter and type in terminal:

[you@YourComputer bin]$ bash bin/porter.sh -p

script start: 2016-08-07:18:17:47

in handle_args()
-p

adding 
 export PATH=$PATH:/data/viridian/scripts/bash-wp-porter/bin 
to bashrc

      ************
      *** DONE *** 
      ************
      
Everything went as expected: Exiting...
script exited: 2016-08-07:18:17:47
exit: 0  


###2 then source your bashrc:

[you@YourComputer bin]$ source ~/.bashrc

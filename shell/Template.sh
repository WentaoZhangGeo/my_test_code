#!/bin/zsh

#########################################################
# Function  :Rotate application logs                     #
# Platform  :All Linux Based Platform                    #
# Version   :1.0                                         #
# Date      :2017-07-28                                  #
# Author    :wzhang                               #
# Contact   :zhangwentaoucas@gmail.com                                #
#########################################################

# Get the source directory of this script
script_dir=$(cd $(dirname "$0") && pwd)
cd $script_dir
echo $script_dir

func1(){
    #do sth
}

func2(){
    #do sth
}



main(){

}

# invoke main function
main|tee ${logfile}
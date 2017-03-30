#!/bin/bash
usage()
{

cat << EOF
usage: $0 options

This script retires sandbox deployment

OPTIONS:
   -h      Show this message
   -p      Use local proxy
EOF

}

VERBOSE=0

while getopts “vhp” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         p)
             USE_PROXY=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ $USE_PROXY -eq 1 ]];
    then

fi

echo -e "\e[100mInstalling ansible roles...\e[m"
make setup  || exit 3

echo -e "  \e[100mHere comes the magic...\e[m"
make install || exit 3

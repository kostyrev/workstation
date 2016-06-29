#!/bin/bash
usage()
{

cat << EOF
usage: $0 options

This script retires sandbox deployment

OPTIONS:
   -h      Show this message
   -p      Use local proxy
   -v      Be verbose
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
         v)
             VERBOSE=1
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

if [[ $VERBOSE -eq 1 ]];
    then
        verbose_arg="--diff"
    else
        verbose_arg=""
fi

if [[ $USE_PROXY -eq 1 ]];
    then
        export http_proxy=http://127.0.0.1:3128
        export https_proxy=http://127.0.0.1:3128
fi

echo -e "\e[100mInstalling ansible roles...\e[m"
ansible-galaxy install -r Ansiblefile.yml --force 1>/dev/null  || exit 3

echo -e "  \e[100mHere comes the magic...\e[m"
ansible-playbook plays/initial.yml ${verbose_arg} --diff || exit 3


#!/bin/bash
usage()
{

cat << EOF
usage: $0 options

This script retires sandbox deployment

OPTIONS:
   -h      Show this message
   -s      Skip sudo configuration
   -p      Use local proxy
   -v      Be verbose
EOF

}

VERBOSE=0

while getopts “vhsp” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             SKIP_SUDO_STEP=1
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
        proxy="http_proxy=http://127.0.0.1:3128"
    else
        proxy=""
fi

echo -e "\e[100mInstalling ansible roles...\e[m"
${proxy} ansible-galaxy install -r Ansiblefile.yml --force 1>/dev/null  || exit 3

if [[ -z ${SKIP_SUDO_STEP} ]];
    then
      echo
      echo -e "\e[100m  Using sudo password for the last time...\e[m"
      ansible-playbook plays/initial.yml ${verbose_arg} --become --ask-become-pass
      echo
fi

echo -e "  \e[100mHere comes the magic...\e[m"
ansible-playbook plays/02_bootstrap.yml ${verbose_arg}

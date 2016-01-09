#!/bin/bash
. /etc/os-release

usage()
{
cat << EOF
usage: $0 options

This script initiates all the magic

OPTIONS:
   -u      Username to authenticate to NTLM proxy
   -d      Domain to authenticate to NTLM proxy
   -i      IP:PORT of NTLM proxy
   -v      cntlm package version [0.92.3-8] as in cntlm-0.92.3-8.fc23.x86_64.rpm
EOF
}

USERNAME=${USER}


case ${REDHAT_SUPPORT_PRODUCT_VERSION} in 
    21)
        CNTLM_VERSION=0.92.3-7
        ;;
    23)    
        CNTLM_VERSION=0.92.3-8
        ;;
esac

HARDWARE_PLATFORM=$(uname -i)

while getopts “hu:d:p:i:v:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         u)
             USERNAME=$(echo ${OPTARG} | tr 'A-Z' 'a-z' )
             ;;
         d)
             DOMAIN=$(echo ${OPTARG} | tr 'A-Z' 'a-z' )
             ;;
         p)
             PASSWD=${OPTARG}
             ;;
         i)
             IP_NTLM_PROXY=${OPTARG}
             ;;             
         v)
             CNTLM_VERSION=${OPTARG}
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $USERNAME ]] || [[ -z $DOMAIN ]] || [[ -z $IP_NTLM_PROXY ]] || [[ -z $CNTLM_VERSION ]]
then
     usage
     exit 1
fi

# __cntlm_is_installed=$(rpm -q cntlm)
rpm -q cntlm >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    read -sp "Password to authenticate to NTLM proxy: " PASSWD
    cd ~/Downloads && { curl -O --proxy-ntlm --proxy-user ${USERNAME}:${PASSWD} --proxy "${IP_NTLM_PROXY}" http://mirror.yandex.ru/fedora/linux/releases/${REDHAT_SUPPORT_PRODUCT_VERSION}/Everything/${HARDWARE_PLATFORM}/os/Packages/c/cntlm-${CNTLM_VERSION}.fc${REDHAT_SUPPORT_PRODUCT_VERSION}.${HARDWARE_PLATFORM}.rpm ; cd -; }
    sudo rpm -Uhv ~/Downloads/cntlm-${CNTLM_VERSION}.fc${REDHAT_SUPPORT_PRODUCT_VERSION}.${HARDWARE_PLATFORM}.rpm
fi

CNTLM_CONFIG=$(rpm -qc cntlm | grep '\.conf$')

grep ${USERNAME} ${CNTLM_CONFIG} >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    NTLM_HASH=$(cntlm -H -u ${USERNAME} -d ${DOMAIN} -p ${PASSWD})
fi    

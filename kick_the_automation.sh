#!/bin/bash

. /etc/os-release

usage()
{
cat << EOF
usage: $0 options

This script initiates all the magic

OPTIONS:
   -u      Username to authenticate to NTLM proxy. By default \${USER}
   -d      Domain to authenticate to NTLM proxy
   -i      IP:PORT of NTLM proxy
   -v      cntlm package version [0.92.3-8] as in cntlm-0.92.3-8.fc23.x86_64.rpm
EOF
}

prompt_for_password() {
    read -sp "Enter the password to authenticate to NTLM proxy: " PASSWD
}

render_config() {
cat <<EOF | sudo tee /etc/cntlm.conf >/dev/null

Username    ${USERNAME}
Domain      ${DOMAIN}
${NTLM_HASH}

Proxy       ${IP_NTLM_PROXY}

Listen      127.0.0.1:3128

EOF

}

ansible_is_available() {
    echo -e "\e[32mAnd finally we've got ansible! Now we can do whatever we want!\e[m"
    echo
    echo "Now run:"
    echo -e "  \e[100m./dance_for_me_monkey.sh \e[m"
}

USERNAME=${USER}


case ${REDHAT_SUPPORT_PRODUCT_VERSION} in 
    21)
        CNTLM_VERSION=0.92.3-7
        RPM_PROXY_CONFIG=/etc/yum.conf
        ;;
    23)    
        CNTLM_VERSION=0.92.3-8
        RPM_PROXY_CONFIG=/etc/dnf/dnf.conf
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

if [ ! -f ~/Downloads/cntlm-${CNTLM_VERSION}.fc${REDHAT_SUPPORT_PRODUCT_VERSION}.${HARDWARE_PLATFORM}.rpm ];
    then
        prompt_for_password
        if [ ! -z ${PASSWD} ]; then
            cd ~/Downloads && { curl -O --proxy-ntlm --proxy-user ${USERNAME}:${PASSWD} --proxy "${IP_NTLM_PROXY}" http://mirror.yandex.ru/fedora/linux/releases/${REDHAT_SUPPORT_PRODUCT_VERSION}/Everything/${HARDWARE_PLATFORM}/os/Packages/c/cntlm-${CNTLM_VERSION}.fc${REDHAT_SUPPORT_PRODUCT_VERSION}.${HARDWARE_PLATFORM}.rpm ; cd -; }
        fi
    else
        rpm -q cntlm >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            sudo rpm -Uhv ~/Downloads/cntlm-${CNTLM_VERSION}.fc${REDHAT_SUPPORT_PRODUCT_VERSION}.${HARDWARE_PLATFORM}.rpm
        fi
fi

CNTLM_CONFIG=$(rpm -qc cntlm | grep '\.conf$')

sudo grep ${USERNAME} ${CNTLM_CONFIG} >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    if [ -z ${PASSWD} ]; then
        prompt_for_password
    fi

    NTLM_HASH=$(echo ${PASSWD} | cntlm -H -u ${USERNAME} -d ${DOMAIN} | grep PassNTLMv2)
    render_config
    sudo chkconfig cntlm on
    sudo service cntlm start
fi

sudo service cntlm status >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    sudo service cntlm start
    if [[ $? -ne 0 ]]; then
        echo "Failed to start cntlm service"
        exit 3
    fi        
fi

grep proxy ${RPM_PROXY_CONFIG} >/dev/null

if [[ $? -ne 0 ]]; then
    echo 'proxy=http://127.0.0.1:3128' | sudo tee -a ${RPM_PROXY_CONFIG} 1>/dev/null
fi

rpm -q ansible >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    sudo yum install ansible -y
    if [[ $? -eq 0 ]]; then
        ansible_is_available
    else
        echo -e "\e[41m $0 failed to install ansible!\e[m"
    fi
else
    ansible_is_available
fi

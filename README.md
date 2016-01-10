After rebuilding OS on my workstations I want to run just one command to re-configure them.

### Behind NTLM proxy
At my work one cannot simply install git, ansible.  
One have to install cntlm to be able to download all the packages.  
So it goes like this:
  - manually configure Mozilla's proxy settings to point to corporate proxy
  - download https://github.com/kostyrevaa/workstation/archive/master.zip
  - unzip it and run `kick_the_automation.sh` passing IP of corporate proxy and DOMAIN as options. This will
    - download cntlm
    - configure it
    - configure yum (dnf) to work through the cntlm
    - download ansible and then

### Provision workstation with ansible
ansible-playbook -i "localhost," packages.yml --diff --ask-sudo-pass

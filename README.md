After rebuilding OS on my workstations I want to run just one command to re-configure them.

### Behind NTLM proxy
At Kaspersky Lab one cannot simply install git, ansible.  
One have to configure some sort of a proxy server (I prefer cntlm) to be able to download any packages.  
So it goes like this:
  - manually configure Mozilla's proxy settings to point to corporate proxy
  - download https://github.com/kostyrevaa/workstation/archive/master.zip
  - unzip it and run `./kick_the_automation.sh` passing IP of corporate proxy and DOMAIN as options. This will
    - download cntlm
    - configure it
    - configure yum (dnf) to work through the cntlm
    - download ansible
  - run `source use_proxy` to export proxy settings

### Run Ansible
execute `make`

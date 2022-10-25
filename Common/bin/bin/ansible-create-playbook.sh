#!/usr/bin/env bash

# Script to create ansible playbook directories
# With thanks to https://gist.github.com/skamithi/11200462 for giving me the idea

# We attempt to lay everything out according to Ansible best practices:
# https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#playbooks-best-practices#directory-layout

gitinit(){
    # Start with sensible .gitignore defaults
    curl -L "https://www.gitignore.io/api/osx,linux,windows,ansible" > .gitignore
    git init
}


usage(){
cat <<EOF
Usage:
$0 -p <Name> [-r <Role1>] [-r <Role2>] [-g <Ansible-GalaxyRole1>] [-g <AnsibleGalaxyRole2>]
-p      Playbook name
-r	Define a role.  (Can be used multiple times)
-g	Define a role to import from Ansible Galaxy.  (Can be used multiple times)
-f	Force creation of playbook, even if it already exists
-G	DO NOT create a GIT repository for the new playbook
EOF
}


HELP=false
PLAYBOOK=false
NEWROLES=(common)
GALAXYROLES=()
FORCE=false
GIT=true

# File/Dir names
GIT_README=README.md
GIT_LICENSE=LICENSE.md
PLAYBOOK_MASTER=site.yml
PLAYBOOK_HOSTS=hosts
ANSIBLE_DIRS=(global_vars group_vars host_vars library module_utils filter_plugins roles)

while getopts :hp:r:g:fG OPTION
do
    case $OPTION in
        h)HELP=true
          ;;
	p)PLAYBOOK=$OPTARG
	  ;;
	r)NEWROLES+=($OPTARG)
	  ;;
	g)GALAXYROLES=($GALAXYROLES $OPTARG)
          ;;
	f)FORCE=true
	  ;;
	G)GIT=false
	  ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [[ $HELP == true ]]; then
    usage;
    exit 0;
fi

if [[ $PLAYBOOK == false ]]; then
    usage;
    exit 1;
fi

if [[ -d $PLAYBOOK && $FORCE != true ]]; then
    echo "Playbook already exists!"
    exit 1;
fi

# create playbook
mkdir -p $PLAYBOOK
cd $PLAYBOOK

for i in ${ANSIBLE_DIRS[@]}; do
    mkdir -p ${i}
done

touch $GIT_README $GIT_LICENSE
touch $PLAYBOOK_MASTER $PLAYBOOK_HOSTS

if [[ $GIT == true ]]; then
    gitinit
fi

for i in ${NEWROLES[@]}; do
    if [[ ! -d "roles/$i" ]]; then
	echo "Creating role: $i"
	ansible-galaxy init ${i} --init-path=roles
    else
	echo "Role already exists: $i"
    fi
done
for i in ${GALAXYROLES[@]}; do
    ansible-galaxy install ${i} -p roles
done
exit 0

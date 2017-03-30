SHELL=/usr/bin/env bash

.PHONY: all setup lint roles

all: setup

clear-cache:
	@rm -fr /tmp/ansible_facts/*
	@rm -fr ~/.ansible/tmp/*
	@rm -fr ~/.ansible/cp/*

setup: lint roles install

lint:
	@pip install --quiet --user -r requirements.txt
	@pre-commit install

roles:
	@ansible-galaxy install --ignore-certs -r Ansiblefile.yml

install:
	ansible-playbook plays/workstation.yml --diff -c local --ask-become-pass

update:
	ansible-playbook plays/update-packages.yml --diff -c local --ask-become-pass


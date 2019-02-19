#!/bin/bash

printf $(kubectl.sh get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

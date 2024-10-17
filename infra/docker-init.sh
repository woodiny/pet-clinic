#!/bin/bash

# sonarqube container
docker run -d --name sonar -p 9000:9000 sonarqube

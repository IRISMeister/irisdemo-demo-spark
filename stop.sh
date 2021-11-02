#!/bin/bash
docker-compose down
sudo rm -fR zeppelin2/shared/zeppelin/logs
sudo rm -fR zeppelin2/shared/zeppelin/conf
sudo rm -fR zeppelin/shared/logs/*

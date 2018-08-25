#!/bin/sh

docker node update --label-add app_host=postgres manager-01
docker node update --label-add app_host=redis manager-02

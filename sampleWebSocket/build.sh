#!/bin/bash

docker build -t websockets-test:1.0 .
docker tag websockets-test:1.0 dubaek/websockets-test:1.0
docker push dubaek/websockets-test:1.0

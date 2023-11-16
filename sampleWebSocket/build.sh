#!/bin/bash

docker build -t websockets-test:1.0 .
docker tag websockets-test:1.0 dubaek/websockets-test:1.0
docker push dubaek/websockets-test:1.0

# server side test
docker run --name run-websockets-test --publish 32080:80 --rm \
    websockets-test:1.0

# client side test
pip install websockets
python3 -m websockets ws://localhost:32080/

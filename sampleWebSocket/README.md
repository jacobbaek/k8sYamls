# Sample websocket application
refer to https://websockets.readthedocs.io/en/latest/howto/kubernetes.html link.

# How to use
build and push
```
docker build -t websockets-test:1.0 .
docker tag websockets-test:1.0 dubaek/websockets-test:1.0
docker push dubaek/websockets-test:1.0
```

run at local machine
```
# Server
docker run --name run-websockets-test --publish 32080:80 --rm \
    websockets-test:1.0

# Client
pip install websockets
python3 -m websockets ws://localhost:32080/
```

# yamls 
kubernetes yaml files at the /yamls directory.


# Introduce
Test script for mtls with ingress-nginx

# How to run
```
# before start, should check your ingressclass (default value is nginx)
# if you don't have ingress-nginx, should install first.
bash start_mtls.sh
```

# how to test

```
$ curl -kv --resolve demo.example.com:443:x.x.x.x https://demo.example.com
400 Bad Request
$ curl -kv --resolve demo.example.com:443:x.x.x.x https://demo.example.com --key certs/client.key --cert certs/client.crt
200 OK
```

```
# "Verify return code: 20 (unable to get local issuer certificate)" error will be shown because it is self-signed cert
openssl s_client -connect x.x.x.x:443 -servername demo.example.com -cert certs/client.crt  -key certs/client.key -CAfile certs/ca.crt -verify_return_error
# below option will skip the verification
openssl s_client -connect x.x.x.x:443 -servername demo.example.com -cert certs/client.crt  -key certs/client.key -CAfile certs/ca.crt -ign_eof
```

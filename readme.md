# mx2-simple
Simple docker container for a postfix relay only server. The idea is to use it as backup mx for your domain. It simply sends emails to relay host as soon the main mx is available. This is handy in case of migrations or maintance of the main mail server(s)

## Features
- Simple configration  
  Only needs ``HOST_DOMAINS`` and ``HOST_RELAY`` environments
  
- Lets encrypt support  
  The container also issues automatically a letsencrypt certificate for the relay. Provide a valid FQDN (``--hostname`` option) whose IP points to your docker host if encryption shoud be enabled.

- Logging to stdout

## Examples


* Minimal (No letsencrypt, docker provided hostname)
```shell
docker pull laubair/mx2-simple
docker run -e RELAY_DOMAINS=example.com -e RELAY_HOST=mx1.example.com -p 25:25 laubair/mx2-simple
```

* With letsencrypt
```shell
docker pull laubair/mx2-simple
docker run -e RELAY_DOMAINS=example.com -e RELAY_HOST=mx1.example.com --hostname=mx2.example.com -p 25:25 -p 80:80 laubair/mx2-simple
```
Exposing of port 80 needed for letsencrypt domain verification

* Specifiy a relay_recipients list
```shell
docker pull laubair/mx2-simple
docker run -e RELAY_DOMAINS=example.com -e RELAY_HOST=mx1.example.com --hostname=mx2.example.com -v /home/user/mx2-simple/relay_recipients:/etc/postfix/relay_recipients -p 25:25 -p 80:80 laubair/mx2-simple
```
See postifx [doc](http://www.postfix.org/STANDARD_CONFIGURATION_README.html#backup) for format of relay_recipients list.

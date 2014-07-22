# logstash-forwarder

Chef cookbook for installing and configuring the Logstash Forwarder

# Attributes

The following attributes will need to be defined:
* ``` node['logstash-forwarder']['cdn_url'] ``` - Where this package going to be pulled from
* ``` node['logstash-forwarder']['collector_ip'] ``` - What is the IP the forwarder will send to (aka Logstash)
* ``` node['logstash-forwarder']['port'] ``` - What is the Port that the forwarder will communicate to the reciever on
* ``` node['ssl_cert_name'] ``` - What is the name of the SSL cert that is going to be used
* ``` node['logstash-forwarder']['template'] ``` - What is the name of the template that will be included
* ``` node['logstash-forwarder']['cookbook'] ``` - What is the name of the cookbook that the rendered template resides

# Rendered Template

The template which is to be rendered inside the /etc/lumberjack.conf file might look something like this:

```
"files": [
          {
            "paths": [ "/var/log/auth.log" ],
            "fields": { "type": "auth" }
          },
          {
            "paths": [ "/var/log/ufw.log" ],
            "fields": { "type": "syslog" }
          }
        ]
```

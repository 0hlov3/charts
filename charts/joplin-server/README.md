# Joplin Server Chart

## Create Mail Secret
Create Mail Secret if `.Values.joplin.mailer.enabled` is set to `true`
```shell
k create secret generic joplin-mailer \
--from-literal=mailerAuthPassword='' \
--from-literal=mailerHost='' \
--from-literal=mailerport='' \
--from-literal=mailerSecure='' \
--from-literal=mailerAuthUser='' \ 
--from-literal=mailerNoreplyName='' \
--from-literal=mailerNoreplyEmail='' 
```
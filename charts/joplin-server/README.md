# Joplin Server Chart

## Add the Chart
```shell
helm repo add schoenwald https://charts.schoenwald.aero
helm repo update schoenwald
```

## Show version
```shell
helm search repo schoenwald/joplin-server
```

## Create Namespace
```shell
kubectl create namespace joplin --dry-run=client -o yaml | kubectl apply -f -
```
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

### Deploy
```shell
helm upgrade --install joplin schoenwald/joplin-server --namespace joplin --create-namespace
```
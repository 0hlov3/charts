# Joplin Server Chart

## Add the Chart
```shell
helm repo add fsociety https://charts.fsociety.social
helm repo update fsociety
```

## Show version
```shell
helm search repo fsociety/joplin-server
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
helm upgrade --install joplin fsociety/joplin-server --namespace joplin --create-namespace
```
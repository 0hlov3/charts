# Matrix Synapse Helm (WIP - Do not Use yet)

## Create the Namespace
```shell
kubectl create namespace synapse
```

## Create the Secrets
### registration_shared_secret
```shell
kubectl create secret --namespace synapse generic synapse-registration-secret --from-literal=registration-shared-secret="$(openssl rand -hex 16)"
```
### macaroon_secret_key
```shell
kubectl create secret --namespace synapse generic synapse-macaroon-secret --from-literal=macaroon-secret-key="$(openssl rand -hex 16)"
```
### email
```shell
kubectl create secret --namespace synapse generic synapse-mail-secret \
  --from-literal=smtp-host=${MAILSERVER} \
  --from-literal=smtp-port=${MAILSERVER_PORT} \
  --from-literal=smtp-user=${MAILSERVER_USER} \
  --from-literal=smtp-pass=${MAILSERVER_PASSWORD}
```
### PostgreSQL
```shell
kubectl create secret --namespace synapse generic synapse-redis-secret --from-literal=redis-pass="$(openssl rand -hex 16)"
```
### Redis
```shell
kubectl create secret --namespace synapse generic synapse-postgresql-secret --from-literal=username="$(openssl rand -hex 16)" --from-literal=password="$(openssl rand -hex 16)"
```
### If Captcha Enabled
```shell
kubectl create secret --namespace synapse generic synapse-captcha-secret --from-literal=recaptcha-public-key="${SYNAPSE_RECAPTCHA_PUBLIC_KEY}" --from-literal=recaptcha-private-key="${SYNAPSE_RECAPTCHA_PRIVATE_KEY}"
```
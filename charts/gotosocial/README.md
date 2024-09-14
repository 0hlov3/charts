# GoToSocial HELM Chart


## IMPORTANT CHANGED
1. We decluttered the values and config file so that you can work on the chart again and have a bit of an overview
2. Please Check if you Changes some default Values from the Chart, if yes, it should be able to put the Config Parameter as they are in [config.yaml](https://github.com/superseriousbusiness/gotosocial/blob/f1cbf6fb761670e10eb8e3fecdc57578733186a1/example/config.yaml) to gotosocial.config.extraConfig
3. The SQLite config is now under the postgreSQL configs, please check out the changes you did here.
4. Test if everything is in Place
   ```shell
   helm upgrade --install gts fsociety/gotosocial --namespace default --create-namespace -f ./values.yaml --dry-run --debug
   ```
   or if you check out the repo and `cd charts/gotosocial`
   ```shell
   helm template --debug gts . -f values.yaml -f yourvalues.yaml
   ```
5. initContainers should work now.
   ```yaml
   initContainers:
     - name: init-myservice
       image: busybox:1.28
       command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets"]
   ```
6. If everything looks fine and you are sure you can start to deploye, set the refactoringAccepted in your values.yaml
   ```shell
   refactoringAccepted: "yes"
   ```

Please do not hesitate to ask if you have any questions!

## Deployment
### Create Namespace
```shell
kubectl create ns gts-test
```
### Create a PostgreSQL-Secret
```shell
kubectl create secret generic gts-postgresql-secret --from-literal="password=$(openssl rand -hex 32)" --from-literal="postgres-password=$(openssl rand -hex 32)" -n gts-test
```
### Deploy Helm Chart
```shell
helm repo add fsociety https://charts.fsociety.social
helm repo update
helm upgrade --install gotosocial fsociety/gotosocial --namespace gotosocial --create-namespace --set gotosocial.config.host='domain.tld' --set gotosocial.config.accountDomain='domain.tld'
```
## Create first User
```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account create --username $USERNAME --email $USER_EMAIL --password $USER_PASS
```

```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account confirm --username $USERNAME
```

```shell
kubectl exec -ti $CONTAINER_ID -- /gotosocial/gotosocial --config-path /config/config.yaml admin account promote --username $USERNAME
```
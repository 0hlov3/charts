# The Lounge HELM Chart

## Deploy
```shell
helm repo add fsociety https://charts.fsociety.social
helm repo update fsociety
helm upgrade --install thelounge fsociety/thelounge --namespace thelounge --create-namespace
```

## Create a User
```shell
kubectl exec -ti thelounge-$ID -- thelounge add $USERNAME
```
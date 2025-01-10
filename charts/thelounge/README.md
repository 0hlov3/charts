# The Lounge HELM Chart

## Deploy
```shell
helm repo add schoenwald https://charts.schoenwald.aero
helm repo update schoenwald
helm upgrade --install thelounge schoenwald/thelounge --namespace thelounge --create-namespace
```

## Create a User
```shell
kubectl exec -ti thelounge-$ID -- thelounge add $USERNAME
```
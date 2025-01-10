[![Release Charts](https://github.com/fSocietySocial/charts/actions/workflows/release.yml/badge.svg)](https://github.com/fSocietySocial/charts/actions/workflows/release.yml)
[![pages-build-deployment](https://github.com/fSocietySocial/charts/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/fSocietySocial/charts/actions/workflows/pages/pages-build-deployment)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/focietyocial-charts)](https://artifacthub.io/packages/search?repo=focietyocial-charts)
# Helm Charts
Find your favorite application and launch it. :)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```shell
helm repo add schoenwald https://charts.schoenwald.aero
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
fsociety` to see the charts.

To install the <chart-name> chart:

```shell
helm install my-<chart-name> schoenwald/<chart-name>
```

To uninstall the chart:
```shell
helm delete my-<chart-name>
```
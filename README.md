# Helm Charts
Find your favorite application and launch it. :)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```shell
helm repo add fsociety https://charts.fsociety.social
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
fsociety` to see the charts.

To install the <chart-name> chart:

```shell
helm install my-<chart-name> <alias>/<chart-name>
```

To uninstall the chart:
```shell
helm delete my-<chart-name>
```

## Need Help?
- [#charts:fsociety.social @ Matrix](https://matrix.to/#/#charts:fsociety.social)

## Want to Contribute?
- [#chart-development:fsociety.social @ Matrix](https://matrix.to/#/#chart-development:fsociety.social)
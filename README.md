[![Release Charts](https://github.com/0hlov3/charts/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/0hlov3/charts/actions/workflows/release.yml)
[![pages-build-deployment](https://github.com/0hlov3/charts/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/0hlov3/charts/actions/workflows/pages/pages-build-deployment)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/schoenwald)](https://artifacthub.io/packages/search?repo=schoenwald)

# 0hlov3s Helm Charts

Effortlessly deploy your favorite applications with Helm! This repository contains a collection of Helm charts for various applications and personal use, ranging from favorites to experimental setups. Whether you’re just starting out or are a seasoned Helm user, maybe there's something here for you.

---

## Repository Overview

This repository features a variety of Helm charts tailored to streamline your deployments. Some of these charts I actively use, while others are community-driven or experimental. Your contributions are more than welcome to make them even better! ❤️

---

## Getting Started

### Prerequisites

Ensure you have [Helm](https://helm.sh) installed. If not, check out Helm's [documentation](https://helm.sh/docs) for installation instructions and an overview of how Helm works.

### Adding the Repository

Once Helm is set up, add the Schoenwald Charts repository:

```shell
helm repo add schoenwald https://charts.schoenwald.aero
```

### Updating the Repository

If you’ve added this repo before, update it to fetch the latest chart versions:

```shell
helm repo update
```

### Searching for Charts

Find available charts by searching the repository:

```shell
helm search repo schoenwald
```

---

## Installing a Chart

To install a specific chart, use the following command:

```shell
helm install <chart-name> schoenwald/<chart-name>
```

Replace `<chart-name>` with the name of the chart you want to install.

### Example

Installing the `awesome-app` chart:

```shell
helm install cinnyapp schoenwald/cinnyapp
```

---

## Uninstalling a Chart

To uninstall a chart:

```shell
helm delete <chart-name>
```

---

## 🌟 Contributing

Your ideas, bug fixes, and enhancements are highly appreciated! Whether it's a bug report, feature request, or a pull request, your contributions make this repository better for everyone.

### How to Contribute

1. Fork the repository.
2. Make your changes.
3. Open a pull request.

For any issues or questions, feel free to open a GitHub issue. Let's build something great together!

---

## 📜 License

This repository is open-source and licensed under the [Apache License 2.0](./LICENSE).

---

## 🧭 Links

- [Helm Documentation](https://helm.sh/docs)
- [Artifact Hub Repository](https://artifacthub.io/packages/search?repo=schoenwald)
- [Repository Issues](https://github.com/0hlov3/charts/issues)

Happy Helm-ing! ⚓

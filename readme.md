# Garage S3 Helm Chart

Helm chart to deploy a single-node [Garage](https://garagehq.deuxfleurs.fr)
(S3-compatible object storage) to Kubernetes. It runs one node with
`replication_factor=1` (no clustering/node discovery), keeps upstream security
hardening and optional Prometheus monitoring, and can optionally bootstrap a
bucket + access key on first boot.

## Configuration

The default configuration for this Helm chart is defined in the [values.yaml](./garage/values.yaml) file.
For detailed descriptions of all the configurable parameters, refer to the provided [values.reference.yaml](./garage/values.reference.yaml) file.
This file serves as the reference for all available settings and their default values. Do not use this for deployment.

## Manual Installation

You can pull and install the Helm chart directly from the OCI registry.

### Install Using OCI Registry

```bash
helm install <release-name> oci://ghcr.io/aboutbits/helm-garage/garage --version <chart-version> --values values-<env>.yaml --namespace <namespace>
```

## Build & Publish

To build and publish the chart, visit the GitHub Actions page of the repository and trigger the workflow "Release Package" manually.

## Information

About Bits is a company based in South Tyrol, Italy. You can find more information about us on [our website](https://aboutbits.it).

### Support

For support, please contact [info@aboutbits.it](mailto:info@aboutbits.it).

### Credits

- [All Contributors](../../contributors)

### License

The MIT License (MIT). Please see the [license file](license.md) for more information.

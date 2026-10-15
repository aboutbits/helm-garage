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

## Cluster Layout

A fresh Garage node serves no S3 traffic until it has a cluster layout. By default (`garage.singleNode: true`) the chart starts Garage with `--single-node`, and Garage creates the layout itself on first boot. In this mode Garage refuses to start once the layout version is higher than 1, so nothing else may change the layout.

To let the [AboutBits Garage Operator](https://github.com/aboutbits/garage-operator) manage the layout with a `GarageCluster`, set `garage.singleNode: false`. Garage then starts without a layout until the operator applies one. The probes are TCP checks for this reason: the admin API's `/health` answers 503 until there is a layout, so a probe on it would keep the Pod out of the Service the operator connects through. `bootstrap.enabled` needs single-node mode, because Garage accepts `--default-bucket` only there; create the bucket and the key with the operator's `Bucket` and `AccessKey` instead.

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

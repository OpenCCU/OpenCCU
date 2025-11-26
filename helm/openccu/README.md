# OpenCCU

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: snapshot](https://img.shields.io/badge/AppVersion-snapshot-informational?style=flat-square)

This is a helm chart for [OpenCCU](https://openccu.de/)

## Installing the Chart

Since this chart depends on HW to manage Homemtatic devices the setup goes beyond just installing the chart.

Please follow the [OpenCCU Kubernetes installation Wiki](https://github.com/OpenCCU/OpenCCU/wiki/Installation-Kubernetes) to deploy.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"ghcr.io/openccu/openccu"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0] | string | `"chart-example.local"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe | object | `{"failureThreshold":5,"initialDelaySeconds":60,"periodSeconds":60,"tcpSocket":{"port":"http"},"timeoutSeconds":5}` | livenessProbe settings |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` | How to access the storage claim |
| persistence.enabled | bool | `true` | enabling persistent data. Dissable for demos |
| persistence.existingClaim | string | a new claim is created | Reuse an existing claim |
| persistence.hostPath | string | a new claim is created |  Use a particular volume on the host machine |
| persistence.size | string | `"1Gi"` | Size for storage claim |
| persistence.storageClass | string | the default storageClassName is used | Use a particular class instead of the default |
| podSecurityContext | object | `{}` |  |
| readinessProbe | object | `{"failureThreshold":60,"periodSeconds":5,"tcpSocket":{"port":"http"},"timeoutSeconds":4}` | readinessProbe settings |
| resources | object | `{}` |  |
| securityContext.privileged | bool | `true` | Use privileged to access the Homematic HW  |
| service.loadBalancerIP | string | `""` |  |
| service.ports.TCP.hmip | int | `2010` | crRFD Legacy XmlRpc - Homematic IP |
| service.ports.TCP.hmip-proxy | int | `32010` | crRFD Legacy XmlRpc - Homematic IP proxy |
| service.ports.TCP.hmip-tls | int | `42010` | crRFD Legacy XmlRpc - Homematic IP TLS |
| service.ports.TCP.http | int | `80` |  |
| service.ports.TCP.https | int | `443` |  |
| service.ports.TCP.rega | int | `8181` | Rega |
| service.ports.TCP.rega-proxy | int | `8183` | Rega proxy |
| service.ports.TCP.rega-tls | int | `48181` | Rega TLS |
| service.ports.TCP.rfd | int | `2001` | wireless Homematic (rfd) |
| service.ports.TCP.rfd-proxy | int | `32001` | wireless Homematic (rfd) proxy |
| service.ports.TCP.rfd-tls | int | `42001` | wireless Homematic (rfd) TLS |
| service.ports.TCP.ssh | int | `22` |  |
| service.ports.TCP.virt-dev | int | `9292` | HMServer - Virtual Devices |
| service.ports.TCP.virt-dev-proxy | int | `39292` | HMServer - Virtual Devices |
| service.ports.TCP.virt-dev-tls | int | `49292` | HMServer - Virtual Devices TLS |
| service.ports.TCP.wired | int | `2000` | wired Homematic (HS485D XmlRpc) |
| service.ports.TCP.wired-proxy | int | `32000` | wired Homematic (HS485D XmlRpc) proxy |
| service.ports.TCP.wired-tls | int | `42000` | wired Homematic (HS485D XmlRpc) TLS |
| service.ports.TCP.xmlrpc | int | `1999` | ReGaHss XmlRpc |
| service.ports.TCP.xmlrpc-proxy | int | `31999` | ReGaHss XmlRpc proxy |
| service.ports.TCP.xmlrpc-tls | int | `41999` | ReGaHss XmlRpc TLS |
| service.ports.UDP.eq3configd | int | `43439` | eq3configd |
| service.ports.UDP.snmp | int | `161` |  |
| service.ports.UDP.upnp | int | `1900` | uPnP/ssdp |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` |  |
| tolerations | list | `[]` |  |

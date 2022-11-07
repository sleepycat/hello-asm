# Hello Anthos Service Mesh

This is a little project to show how to integrate [Anthos Service Mesh](https://cloud.google.com/anthos/service-mesh) (ASM), Google's managed version of Istio, [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview) and [cert-manager](https://cert-manager.io/). The appeal of combining these is that together they should give both a great security posture and a "NoOps" experience.

## Running it
Change the variables at the top of the Makefile to fit your project and then run the following commands:

```sh
make cluster 
make add-to-fleet
# check that your revision is deployed and active
make describe-mesh
make apply-config
```

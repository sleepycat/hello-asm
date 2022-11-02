# Hello Anthos Service Mesh

This is a little project to help explore ASM, Google's managed version of Istio, while running it on GKE Autopilot. The appeal of combining those two services is that together they should give both a great security posture and a "NoOps" experience.

## Running it
Change the variables at the top of the Makefile to fit your project and then run the following commands:

```sh
make cluster 
make add-to-fleet
# check that your revision is deployed and active
make describe-mesh
make apply-config
```

## TODO
Figure out how to use cert-manager with ASM/Autopilot. Customized config created but not yet used.

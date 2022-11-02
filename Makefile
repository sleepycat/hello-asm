#################################################################################
# GLOBALS                                                                       #
#################################################################################

project = phsx-sp-sdi-livebrant
project_number = 145891259449
name = helloasm
region = northamerica-northeast1

.PHONY: cluster
cluster:
		gcloud container --project "$(project)" clusters create-auto "$(name)" --region "$(region)" --release-channel "rapid"

.PHONY: add-to-fleet
add-to-fleet:
		gcloud container --project "$(project)" clusters create-auto "$(name)" --region "$(region)" --release-channel "rapid"
		gcloud container fleet memberships register "$(name)" --gke-uri=https://container.googleapis.com/v1/projects/"$(project)"/locations/"$(region)"/clusters/"$(name)" --enable-workload-identity --project "$(project)"
		gcloud projects add-iam-policy-binding "$(project)" --member "serviceAccount:service-$(project_number)@gcp-sa-servicemesh.iam.gserviceaccount.com" --role roles/anthosservicemesh.serviceAgent
		gcloud container clusters update  --project "$(project)" "$(name)" --region "northamerica-northeast1" --update-labels "mesh_id=proj-$(project_number)"
		gcloud container fleet mesh update --management automatic --memberships "$(name)" --project "$(project)"
		
.PHONY: describe-mesh
describe-mesh:
		gcloud container fleet mesh describe --project "$(project)"

.PHONY: apply-config
apply-config:
		kubectl apply -k .

# This regenerates the istio manifests while using yq to remove the CRD for the
# operator so it doesn't clash with the istio operator which also includes the
# CRD
.PHONY: update-istio
update-istio:
		istioctl manifest generate --revision asm-managed --dry-run > istio/istio.yaml

.PHONY: print-ingressgateway-service
print-ingressgateway-service:
		kustomize build | yq -y '. | select(.kind == "Service" and .metadata.name == "istio-ingressgateway")'



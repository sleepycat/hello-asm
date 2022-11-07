#################################################################################
# GLOBALS                                                                       #
#################################################################################

# project = phsx-sp-sdi-livebrant
# project_number = 145891259449
# name = helloasm
# region = northamerica-northeast1

project = asmautopilotdemo
project_number = 482488783820
name = helloasm
region = northamerica-northeast1

.PHONY: cluster
cluster:
		gcloud container --project "$(project)" clusters create-auto "$(name)" --region "$(region)" --release-channel "rapid"

.PHONY: add-to-fleet
add-to-fleet:
		gcloud services enable mesh.googleapis.com --project="$(project)"
		gcloud container fleet memberships register "$(name)" --gke-uri=https://container.googleapis.com/v1/projects/"$(project)"/locations/"$(region)"/clusters/"$(name)" --enable-workload-identity --project "$(project)"
		gcloud projects add-iam-policy-binding "$(project)" --member "serviceAccount:service-$(project_number)@gcp-sa-servicemesh.iam.gserviceaccount.com" --role roles/anthosservicemesh.serviceAgent
		gcloud container clusters update  --project "$(project)" "$(name)" --region "$(region)" --update-labels "mesh_id=proj-$(project_number)"
		gcloud container fleet mesh update --management automatic --memberships "$(name)" --project "$(project)"
		
.PHONY: watch-mesh
watch-mesh:
		watch gcloud container fleet mesh describe --project "$(project)"

.PHONY: apply-config
apply-config:
		kubectl apply -k .

# TODO: rework to properly use variables for the ip
.PHONY: setup-dns
setup-dns:
		gcloud services enable dns.googleapis.com
		gcloud dns --project="$(project)" managed-zones create actually-works --description="" --dns-name="actually.works." --visibility="public" --dnssec-state="off"
		gcloud dns --project="$(project)" record-sets create it.actually.works. --zone="actually-works" --type="CAA" --ttl="300" --rrdatas="0 issue "letsencrypt.org""
		gcloud compute addresses create demo-ip --project="$(project)" --region="$(region)"
		gcloud compute addresses describe --region "$(region)" demo-ip --format='value(address)'
		gcloud dns --project="$(project)" record-sets create it.actually.works. --zone="actually-works" --type="A" --ttl="300" --rrdatas="34.152.36.147"

# TODO: should this be folded in elsewhere?
.PHONY: setup-service-account
setup-service-account:
		gcloud iam service-accounts create dns01-solver --display-name "dns01-solver"
		gcloud projects add-iam-policy-binding "$(project)" --member "serviceAccount:dns01-solver@$(project).iam.gserviceaccount.com" --role roles/dns.admin
		gcloud iam service-accounts add-iam-policy-binding --role roles/iam.workloadIdentityUser --member "serviceAccount:$(project).svc.id.goog[cert-manager/cert-manager]" dns01-solver@$(project).iam.gserviceaccount.com

# For debugging... assumes `pip install yq` has happened
.PHONY: print-ingressgateway-service
print-ingressgateway-service:
		kustomize build | yq -y '. | select(.kind == "Service" and .metadata.name == "istio-ingressgateway")'



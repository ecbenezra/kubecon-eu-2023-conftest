package main

import data.functions

# Functions

is_dev {
	input.metadata.labels.env == "dev"
}

# deny K8s objects without an environment label
deny_no_env_label[msg] {
	not input.metadata.labels.env
	msg := sprintf("%v/%v does not contain env label", [input.kind, input.metadata.name])
}

deny_latest_tags[msg] {
	not is_dev

	# container image path for pods
	containerImage := input.spec.containers[_].image
	functions.image_latest_tag(containerImage)
	msg := sprintf("image %v cannot be tagged latest %v/%v", [containerImage, input.kind, input.metadata.name])
}

deny_latest_tags[msg] {
	not is_dev

	# container image path for deployments and replicasets
	containerImage := input.spec.template.spec.containers[_].image
	functions.image_latest_tag(containerImage)
	msg := sprintf("image %v cannot be tagged latest %v/%v", [containerImage, input.kind, input.metadata.name])
}

warn_latest_tags[msg] {
	is_dev
	containerImage := input.spec.containers[_].image
	functions.image_latest_tag(containerImage)
	msg := sprintf("dev image is tagged latest %v/%v. Be aware latest tags are not permitted in stg or prd", [input.kind, input.metadata.name])
}

warn_latest_tags[msg] {
	is_dev
	containerImage := input.spec.template.spec.containers[_].image
	functions.image_latest_tag(containerImage)
	msg := sprintf("dev image is tagged latest %v/%v. Be aware latest tags are not permitted in stg or prd", [input.kind, input.metadata.name])
}

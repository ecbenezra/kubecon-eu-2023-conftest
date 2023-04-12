package main

allowedImages := {"busybox:latest", "vital-image:latest"}

exception[rules] {
	allowedImages[input.spec.template.spec.containers[_].image]
	rules := ["latest_tags"]
}

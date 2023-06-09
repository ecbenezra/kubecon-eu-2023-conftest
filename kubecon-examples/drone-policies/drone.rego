package main

import future.keywords

image_latest_tag(imageName) if {
	endswith(imageName, "latest")
}

deny_no_image_tag contains msg if {
	input.kind == "pipeline"
	not every_image_contains_tag
	msg = sprintf("%v/%v contains images with no tag", [input.kind, input.name])
}

deny_image_latest contains msg if {
	input.kind == "pipeline"
	image = input.steps[_].image
	image_latest_tag(image)
	msg = sprintf("%v/%v contains images with latest tag: %v", [input.kind, input.name, image])
}

every_image_contains_tag if {
	every step in input.steps {
		contains(step.image, ":")
	}
}

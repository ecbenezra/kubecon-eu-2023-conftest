package main

import future.keywords
import data.functions

deny_no_image_tag[msg] {
	not every_image_contains_tag
	msg = sprintf("%v/%v contains images with no tag", [input.kind,input.name])
}

deny_image_latest[msg] {
    image = input.steps[_].image
    functions.image_latest_tag(image)
    msg = sprintf("%v/%v contains images with latest tag", [input.kind,input.name])
}

every_image_contains_tag {
    every step in input.steps {
        contains(step.image, ":")
    }
}
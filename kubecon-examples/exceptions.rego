package main

exception[rules] {
	input.kind == "Deployment"
	startswith(input.metadata.name, "very-important-latest")
	reason = "some performance issues"

	rules := ["latest_tags"]
}

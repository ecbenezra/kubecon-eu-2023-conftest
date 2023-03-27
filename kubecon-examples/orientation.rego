package main

deny[msg] {
    image := input.spec.template.spec.containers[_].image
    endswith(image,"latest")
    msg := sprintf("images cannot be tagged latest %s/%s",[input.kind,input.metadata.name])
}
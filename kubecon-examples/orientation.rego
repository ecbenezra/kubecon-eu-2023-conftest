package main

# deny[msg] {
#     some i
#     image := input.spec.template.spec.containers[i].image
#     endswith(image,"latest")
#     msg := sprintf("image %s cannot be tagged latest %s/%s",[image,input.kind,input.metadata.name])
# }

deny[msg] {
    image := input.spec.template.spec.containers[_].image
    endswith(image,"latest")
    msg := sprintf("image %s cannot be tagged latest %s/%s",[image,input.kind,input.metadata.name])
}


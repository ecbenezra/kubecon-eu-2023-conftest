# Automating Configuration and Permissions Testing for GitOps with OPA Conftest

![kubecon](logo.png)

## Getting Started

This repository contains examples used in the KubeCon + CloudNativeCon EU 2023 Talk *Automating Configuration and Permissions Testing for GitOps with OPA Conftest*

You can pull the policies from this repository with the command

`conftest pull git::https://github.com/ecbenezra/kubecon-eu-2023-conftest.git//kubecon-examples/`

This will add a directory called `policy` which can be used to test configuration with the following command:

`conftest test config/dir/`

This tests using a default policy directory named `policy`. If policies are in a different directory, use the `-p` flag. In this repository, policies are located in `kubecon-examples`, so you can test using the command:

`conftest test -p kubecon-examples/ example-configs/`

## Understanding and Writing Rego

Rego syntax contains logic that isn't necessarily intuitive. The below examples help explain rego using the example of prohibiting latest tags on container images in higher environments (staging and production). These policies build on one another to validate compliance. 

When writing conftest for rego, prefix the configuration path to what you want to test with the word `input`. When looking to require a certain metadata label on a Kubernetes deployment spec, for instance, the path would be `metadata.labels.label-name` and in a Conftest rule, this would be written `input.metadata.labels.label-name`. This `input` refers to the input data that is provided to Conftest at runtime. 

Take a look at the [prd deployment](example-configs/kubernetes/failing-deployment.yaml#L29) and [dev deployment](example-configs/kubernetes/deployment.yaml#L14). We will write policies that govern these deployments and the use of image tags, with the goal to:

* enforce `metadata.labels.env` label to exist and be one of `{"dev", "stg", "prd"}`
* ensure container images are not tagged `latest` in higher-level environments 
* for `dev` environments, return a warning that `latest` tags are not allowed for higher environments

### Enforce Labels

```
allowedEnvs := {"dev", "stg", "prd"}

deny_no_env_label[msg] {
	not input.metadata.labels.env
	msg := sprintf("%v/%v does not contain env label", [input.kind, input.metadata.name])
}

deny_invalid_env_label[msg] {
	not allowedEnvs[input.metadata.labels.env]
	msg := sprintf("%v/%v metadata label must be equal to dev, stg, or prd", [input.kind, input.metadata.name])
}
```

Rego rules are collections of boolean conditions. If all conditions in a rule such as `deny_no_env_label` are true, then the rule will evaluate to `true`, and trigger a denial. 

### Check If Environment Is Dev

```
is_dev {
	input.metadata.labels.env == "dev"
}
```

We can create this function that we can call later. If this is a general-purpose function, it can be put in its own package and imported as data in the main package with `import data.package-name`.

### Deny Latest Tags for Upper Environments

```
deny_latest_tags[msg] {
	not is_dev # if labels.metadata.env != "dev"

	# container image path for deployments and replicasets
	containerImage := input.spec.template.spec.containers[_].image
	endswith(containerImage, "latest")
	msg := sprintf("image %v cannot be tagged latest %v/%v", [containerImage, input.kind, input.metadata.name])
}
```

Since Deployments and ReplicaSets can contain multiple containers, we need to iterate through them. This can be done with an explicit iterator, by calling `some i` in the rule. Since there is only one iterator needed, and the scope is local, we can use a special Rego character `_` to instantiate a new iterator. 

Using the built-in `endswith` function, we can compare the container image to see if it ends with the word "latest". If it does, we'll return the message. 

### Warn For Latest Tags in Lower Environments

```
warn_latest_tags[msg] {
	is_dev # if labels.metadata.env == "dev"

	# container image path for deployments and replicasets
	containerImage := input.spec.template.spec.containers[_].image
	endswith(containerImage, "latest")
	msg := sprintf("dev image is tagged latest %v/%v. Be aware latest tags are not permitted in stg or prd", [input.kind, input.metadata.name])
}
```

This warning is almost identical to our deny rule, with the exception that this is a warning, and it is checking if an `env` label is equal to `dev` instead of checking if it is not equal to `dev`.

## Bundling and Sharing Policies

Policies can be bundled and shared, or downloaded remotely from a URL, specific protocol like Git, or from an OCI registry. 

To create a signed OPA Bundle:

1. Create an RSA Key Pair

```
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

2. Create a `.signatures.json` file

In your policy directory:

`opa sign --signing-key private_key.pem --bundle policy/`

Ensure the `.signatures.json` file is in your bundle directory.

3. Build bundle

`opa build --bundle --signing-key private_key.pem --verification-key public_key.pem policy/`

4. Upload bundle to bundle server 

Upload your bundle to an OPA server using `opa run`; or upload to Git repo or OCI registry to be pulled. 

## Thanks

Special thanks to Mike Hume, g Link, Serhiy Martynenko, Luke Philips, Max Knee, The New York Times Continuous Delivery Platform Team, and the members of The New York Times Delivery Engineering Mission. 
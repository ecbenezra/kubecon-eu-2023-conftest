package main

allowedNamespaceResources := {
	"apps": {"Deployment", "ReplicaSet", "StatefulSet"},
	"policy": {"AnotherKnownPolicy"},
	"networking.istio.io": {"Gateway", "DestinationRule"},
}

deny_namespace_groups[msg] {
	group := input.spec.namespaceResourceWhitelist[_].group
	not allowedNamespaceResources[group]
	msg = sprintf("namespaceResourceWhitelist group %v not permitted", [group])
}

deny_namespace_kinds[msg] {
	some i # since order matters, define explicit iterator
	group := input.spec.namespaceResourceWhitelist[i].group
	kind := input.spec.namespaceResourceWhitelist[i].kind
	allowedKinds := allowedNamespaceResources[group]
	not allowedKinds[kind]
	msg = sprintf("namespaceResourceWhitelist kind %v not allowed for group %v", [kind, group])
}

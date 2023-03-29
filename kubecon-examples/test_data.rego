package main

stg_deployment_with_latest_tag := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "nginx-stg",
		"labels": {
			"app": "nginx",
			"env": "stg",
		},
	},
	"spec": {"template": {"spec": {"containers": [{
		"name": "nginx",
		"image": "nginx:latest",
		"ports": [{"containerPort": 80}],
	}]}}},
}

dev_deployment_with_latest_tag := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "nginx-dev",
		"labels": {
			"app": "nginx",
			"env": "dev",
		},
	},
	"spec": {"template": {"spec": {"containers": [{
		"name": "nginx",
		"image": "nginx:latest",
		"ports": [{"containerPort": 80}],
	}]}}},
}

deployment_no_label := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {"name": "nginx-dev"},
}

stg_pod_with_latest_tag := {
	"apiVersion": "v1",
	"kind": "Pod",
	"metadata": {
		"name": "nginx",
		"labels": {"env": "stg"},
	},
	"spec": {"containers": [{
		"name": "nginx",
		"image": "nginx:latest",
		"ports": [{"containerPort": 80}],
	}]},
}

valid_stg_deployment := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "nginx-stg",
		"labels": {
			"app": "nginx",
			"env": "stg",
		},
	},
	"spec": {"template": {"spec": {"containers": [{
		"name": "nginx",
		"image": "nginx:1.22",
		"ports": [{"containerPort": 80}],
	}]}}},
}

package main

empty(value) {
	count(value) == 0
}

test_deny_stg_deployment {
	deny_latest_tags with input as stg_deployment_with_latest_tag
}

test_warn_dev_deployment {
	warn_latest_tags with input as dev_deployment_with_latest_tag
}

test_deny_no_env_label {
	deny_no_env_label with input as deployment_no_label
}

test_deny_stg_pod {
	deny_latest_tags with input as stg_pod_with_latest_tag
}

test_correctly_tagged_stg_deployment {
	empty(deny_latest_tags) with input as valid_stg_deployment
}

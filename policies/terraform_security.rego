package terraform.security

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_security_group"

  ingress := resource.change.after.ingress[_]
  ingress.from_port <= 22
  ingress.to_port >= 22
  ingress.protocol == "tcp"

  cidr := ingress.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  msg := sprintf("Security group %s allows SSH from 0.0.0.0/0", [resource.address])
}


deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"

  resource.change.after.associate_public_ip_address == true

  msg := sprintf("EC2 instance %s has a public IP address enabled", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_instance"

  not resource.change.after.metadata_options[0].http_tokens == "required"

  msg := sprintf("EC2 instance %s does not require IMDSv2", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_server_side_encryption_configuration"

  not resource.change.after.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm

  msg := sprintf("S3 encryption configuration %s is missing encryption algorithm", [resource.address])
}

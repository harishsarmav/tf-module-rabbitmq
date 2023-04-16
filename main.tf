resource "aws_security_group" "rabbitmq" {
  name        = "${var.env}-rabbitmq-security-group"
  description = "${var.env}-rabbitmq-security-group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "RabbitMQ"
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-rabbitmq-security-group"}
  )
}

resource "aws_mq_configuration" "rabbitmq " {
  description    = "${var.env}-rabbitmq-configuration"
  name           = "${var.env}-rabbitmq-configuration"
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data = ""
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name     = "${var.env}-rabbitmq"
  deployment_mode = "SINGLE_INSTANCE"
  engine_type        = "ActiveMQ"
  engine_version     = "5.15.9"
  host_instance_type = var.host_instance_type
  security_groups    = [aws_security_group.rabbitmq.id]

  configuration {
    id       = aws_mq_configuration.rabbitmq.id
    revision = aws_mq_configuration.rabbitmq.latest_revision
  }

  encryption_options {
    kms_key_id        = ""
    use_aws_owned_key = false
  }

  user {
    username = data.aws_ssm_parameter.USER
    password = data.aws_ssm_parameter.PASS
  }
}
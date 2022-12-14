resource "aws_instance" "app_server" {
  count           = var.node_count
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.app_server_instance_type
  security_groups = [aws_security_group.web-access.name]
  user_data       = file("install_webserver.sh")

  tags = merge({
    Name = "Webserver ${count.index + 1}"
    }, var.common_tags
  )

  depends_on = [
    aws_instance.db_server
  ]

}

resource "aws_security_group" "web-access" {
  name        = "web-access"
  description = "Allow port 80 access from outside world"

  dynamic "ingress" {
    for_each = var.ingress-rules
    content {
      description = ingress.key
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

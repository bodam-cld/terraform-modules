resource "aws_security_group" "alb" {
  name        = var.name
  description = "${var.name} ALB default SG"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.alb.id

  type      = "egress"
  from_port = "0"
  to_port   = "0"
  protocol  = "-1"
  #tfsec:ignore:aws-vpc-no-public-egress-sgr => it is a rule for a public ALB
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow outgoing access to anywhere"
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = aws_security_group.alb.id

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #tfsec:ignore:aws-vpc-no-public-egress-sgr => it is a rule for a public ALB
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow incoming access for HTTP"
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id = aws_security_group.alb.id

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  #tfsec:ignore:aws-vpc-no-public-egress-sgr => it is a rule for a public ALB
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow incoming access for HTTPS"
}

# load balancer
resource "aws_lb" "this" {
  name = var.name
  #tfsec:ignore:aws-elb-alb-not-public => it is a public load balancer
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  ip_address_type            = "ipv4"
  drop_invalid_header_fields = true
}

# listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      status_code  = "404"
    }
  }
}

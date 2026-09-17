resource "aws_lb" "gateway_lb" {
  name                             = var.gwlb_name
  load_balancer_type               = "gateway"
  enable_cross_zone_load_balancing = "true"

  subnet_mapping {
    subnet_id = aws_subnet.subnet["gwlb_a"].id
  }

  subnet_mapping {
    subnet_id = aws_subnet.subnet["gwlb_b"].id
  }

  tags = {
    #Environment = "Production"
  }
}

resource "aws_lb_target_group" "fgt_target" {
  name        = var.gwlb_target_group_name
  port        = 6081
  protocol    = "GENEVE"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    port     = 8008
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "fgt_listener" {
  load_balancer_arn = aws_lb.gateway_lb.id

  default_action {
    target_group_arn = aws_lb_target_group.fgt_target.id
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "fgtattach1" {
  #depends_on       = [aws_instance.fgtvm]
  target_group_arn = aws_lb_target_group.fgt_target.arn
  target_id        = aws_network_interface.fw1_port1.private_ip
  port             = 6081
}
resource "aws_lb_target_group_attachment" "fgtattach2" {
  #depends_on       = [aws_instance.fgtvm2]
  target_group_arn = aws_lb_target_group.fgt_target.arn
  target_id        = aws_network_interface.fw2_port1.private_ip
  port             = 6081
}

resource "aws_vpc_endpoint_service" "fgtgwlbservice" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gateway_lb.arn]
}

resource "aws_vpc_endpoint" "gwlbendpoint1" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.subnet["gwlb_a"].id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "gwlbendpoint2" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.subnet["gwlb_b"].id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.vpc.id
}
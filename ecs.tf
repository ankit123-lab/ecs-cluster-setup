data "aws_iam_role" "iamrole" {
  name = "AWSServiceRoleForECS"
}

data "aws_lb_target_group" "tg" {
  name = "ecsservicetarget"
}

resource "aws_ecs_cluster" "ecscluster" {
  name = "deepdive"
}

# Use ecsInstanceRole for attaching to EC2 Instance

# TBD: Create EC2 Instance with User Data (refer file) - Use AMI - ami-2b3b6041 
resource "aws_instance" "ecscontainer" {
  ami           = "ami-2b3b6041"
  instance_type = "t2.micro"
  key_name      = "ecsinstance" # Change as per your system, Optional
  tags = {
    Name = "ECSINSTANCE"
  }
  iam_instance_profile = "ecsInstanceRole"
  user_data = <<-EOF
              #!/bin/bash
              yum install -y aws-cli
              aws s3 cp s3://mmecsdeepdive/ecs.config /etc/ecs/ecs.config
              EOF
}

resource "aws_ecs_task_definition" "taskdef" {
  family                = "service"
  container_definitions = "${file("web-task-definition.json")}"
}

resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = aws_ecs_cluster.ecscluster.id
  task_definition = aws_ecs_task_definition.taskdef.id
  desired_count   = 2
  launch_type     = "EC2"
  iam_role        = data.aws_iam_role.iamrole.arn

  
  load_balancer {
    target_group_arn = data.aws_lb_target_group.tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
  depends_on = [aws_ecs_task_definition.taskdef]
}

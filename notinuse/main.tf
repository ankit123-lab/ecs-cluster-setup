variable "ecsinstanceami" {
  default = "ami-2b3b6041"
}

variable "ecsclustername" {
  default = "democluster"
}

resource "aws_ecs_cluster" "democluster" {
  name = var.ecsclustername
}

resource "aws_iam_role" "ecsInstanceRole" {
  name               = "ecsInstanceRoleDemo"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "ecsInstancePolicy" {
  name = "AWSECSInstancePolicy"
  role = aws_iam_role.ecsInstanceRole.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
  }
  EOF
}



resource "aws_instance" "ecscontainer" {
  ami           = var.ecsinstanceami
  instance_type = "t2.micro"
  key_name      = "ecsinstance"
  tags = {
    Name = "ECSINSTANCE"
  }
  iam_instance_profile = "ecsInstanceRole"
  user_data = <<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=democluster" > /etc/ecs/cluster.config
              EOF
}

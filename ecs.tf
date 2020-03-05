

data "aws_ecs_cluster" "ecscluster" {
  cluster_name = "deepdive"
}

data "aws_ecs_task_definition" "taskdef" {
  task_definition = "web"
}

data "aws_iam_role" "iamrole" {
  name = "AWSServiceRoleForECS"
}

data "aws_lb_target_group" "tg" {
  name = "ecsservicetarget"
}

output "clusterid" {
  value = data.aws_ecs_cluster.ecscluster.id
}

output "targetgrouparn" {
  value = data.aws_lb_target_group.tg.arn
}

resource "aws_ecs_cluster" "deepdive" {
  name = "deepdive"
}

resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = data.aws_ecs_cluster.ecscluster.id
  task_definition = data.aws_ecs_task_definition.taskdef.id
  desired_count   = 2
  launch_type     = "EC2"
  iam_role        = data.aws_iam_role.iamrole.arn

  
  load_balancer {
    target_group_arn = data.aws_lb_target_group.tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
  
}

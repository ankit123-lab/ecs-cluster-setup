


data "aws_iam_role" "iamrole" {
  name = "AWSServiceRoleForECS"
}

data "aws_lb_target_group" "tg" {
  name = "ecsservicetarget"
}

resource "aws_ecs_cluster" "ecscluster" {
  name = "deepdive"
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

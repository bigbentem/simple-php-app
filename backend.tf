### Variables
variable db_storage {
  default = "20"
}

variable db_engine {
  default = "mysql"
}

variable db_instance_type {
  default = "db.t2.micro"
}

variable db_user {
  default = "admin"
}

variable db_password {
  default = "devops2017"
}

# The name of the database is already in the snapshot
variable db_snapshot {
  default = "arn:aws:rds:eu-west-1:006317450780:snapshot:ini-table"
}

### Resources
resource "aws_db_subnet_group" "mysql" {
  # TO DO
  # see https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html
  name = "${var.project_name}-sgmysql"
  subnet_ids = ["${aws_subnet.public.*.id}"]
}

resource "aws_db_instance" "mysql" {
  # TO DO
  # see https://www.terraform.io/docs/providers/aws/r/db_instance.html
  # create the db from the given snapshot
  allocated_storage = "${var.db_storage}"
  engine = "${var.db_engine}"
  instance_class = "${var.db_instance_type}"
  username = "${var.db_user}"
  password = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.mysql.name}"
  snapshot_identifier = "${var.db_snapshot}"
  skip_final_snapshot = true
  identifier = "${var.project_name}-mydb"
  vpc_security_group_ids = ["${aws_security_group.mysql.id}"]
}

### Outputs
output "mysql_host" {
  # TO DO
  # see https://www.terraform.io/intro/getting-started/outputs.html
  value = "${aws_db_instance.mysql.address}"
}

output "mysql_endpoint" {
  # TO DO
  value = "${aws_db_instance.mysql.endpoint}"
}

output "mysql_db" {
  # TO DO
  value = "${aws_db_instance.mysql.name}"
}

output "mysql_user" {
  # TO DO
  value = "${aws_db_instance.mysql.username}"
}

output "mysql_password" {
  # TO DO
  value = "${var.db_password}"
}

output "mysql_subnet_group_name" {
  value = ["${var.project_name}-sgmysql","${aws_db_subnet_group.mysql.name}"]
}
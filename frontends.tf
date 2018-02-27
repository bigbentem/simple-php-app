### Variables
variable front_instance_number {
  default = "2"
}

variable front_ami {
  default = "ami-0d77397e" # Ubuntu 16.04
}

variable front_instance_type {
  default = "t2.micro"
}

variable public_key {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA1T5MjdYDE+OF2pZeKA8duZie2Rt9UzDcgcnSsbqbVicxDC7DguM9kPSpPtrcg48+G5IaX2VKbm/efRFQLp1n3w3X9bmub2fxpoR4o1cvZ8T+8X3gJjQAUXrq1MOaWNyNUYjPU/LHguQSpUbDFTzvakpfvDq0qeCUqg5Wj5aqR9DbXNbtWMRu9e6Y4e9YYhPlQ1lgL4wDluGQT4e+k1IdvlJ8RBmAILQat7QTWAwRRSibjw7RIgf86V0sGcNWOtzd1lN9fyfYtyGn7ZQkxjYGcETOPce3yjeThIOhz0BJeqFOk0GLupN3+k0gDvxazCfTfDVfhp5egYLZG2rx9/iKIQ== Module42-moi"
}

variable front_instance_port {
  default = "8080"
}

variable front_elb_port {
  default = "8080"
}

variable front_elb_protocol {
  default = "http"
}

### Template for the instances user_data
data "template_file" "init" {
  template = "${file("init.tpl")}"

  vars{
    DBHOST = "${aws_db_instance.mysql.address}"
    DATABASE = "${aws_db_instance.mysql.name}"
    DBUSER = "${var.db_user}"
    DBPASSWORD = "${var.db_password}"
  }
}


### Resources
resource "aws_key_pair" "front" {
  key_name   = "${var.project_name}-front"
  public_key = "${var.public_key}"
}

resource "aws_instance" "front" {
  # TO DO
  # see https://www.terraform.io/docs/providers/aws/r/instance.html
  ami = "${var.front_ami}"
  instance_type = "${var.front_instance_type}"
  count = "${length(var.azs[var.region])}"
  security_groups = ["${aws_security_group.front.id}"]
  subnet_id = "${aws_subnet.public.*.id[count.index]}"
  key_name   = "${var.project_name}-front"
  
  tags {
    Name = "${var.project_name}_front_instance${count.index}"
  }
  user_data = "${data.template_file.init.rendered}"
}

resource "aws_elb" "front" {
  # TO DO
  # see https://www.terraform.io/docs/providers/aws/r/elb.html
  name = "${var.project_name}-elb"
  #availability_zones = ["${var.azs[var.region]}"]
  listener {
    instance_port     = "${var.front_instance_port}"
    instance_protocol = "${var.front_elb_protocol}"
    lb_port           = "${var.front_elb_port}"
    lb_protocol       = "${var.front_elb_protocol}"
  }
  instances = ["${aws_instance.front.*.id}"]
  cross_zone_load_balancing = false
  idle_timeout = 400
  security_groups = ["${aws_security_group.front.id}","${aws_security_group.mysql.id}"]
  subnets = ["${aws_subnet.public.*.id}"]
}

### Outputs
output "elb_endpoint" {
  # TO DO
  # see https://www.terraform.io/intro/getting-started/outputs.html
  value = "${aws_elb.front.*.dns_name}"
}

output "instance_ip" {
  # TO DO
  value = ["${aws_instance.front.*.public_ip}"]
}

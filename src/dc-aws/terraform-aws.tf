provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_instance" "cluster" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    count = 1

    connection {
        user = "terraform"
        key_file = "${var.key_path}"
    }

    provisioner "file" {
        source = "scripts/install.sh"
        destination = "/opt/nomad/"
    }

    provisioner "remote-exec" {
        inline = [
        "cd /opt/nomad",
        ]
    }
}

resource "aws_instance" "cluster" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    count = "${var.count}"

    connection {
        user = "terraform"
        key_file = "${var.key_path}"
    }

    provisioner "file" {
        source = "scripts/install.sh"
        destination = "/opt/nomad/"
    }

    provisioner "remote-exec" {
        inline = [
        "cd /opt/nomad",
        ]
    }
}

resource "aws_instance" "worker" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
}


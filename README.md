# Terraform example

This example lets you create an AWS EC2 instance you can log in to via SSH.

## Preparation

[Download terraform](https://www.terraform.io/downloads.html). You can place the binary wherever you want,
and nothing else is needed.

Configure your aws-vault to get AWS access rights. Docs below will *not* be shown with aws-vault prefix. Use it thus:

    aws-vault <account> exec -- <actual command>

## Usage

### SSH key

Create an SSH keypair (this cannot be currently created by terraform):

    aws ec2 create-key-pair --key-name tfexample --output text | cat

Copy the private key part and paste it into a file in `.ssh`, then add it to your ssh agent. On mac:

    pbpaste > ~/.ssh/tfexample
    chmod 600 ~/.ssh/tfexample
    ssh-add ~/.ssh/tfexample

### Vars

Update `terraform.tfvars` to match your key name you have just created in AWS. While you are here, also set your host IP range
(use CIDR ranges such as 1.2.3.4/32), as well as give it a friendly name via name_tag.

You can also [supply those variables in other ways](https://www.terraform.io/docs/configuration/variables.html), if you don't
like locally editing files in version control.

### Create infra

Initialise terraform:

    terraform init

Now you are ready to create resources:

    terraform apply

Review the plan, and confirm with "yes".

### Accessing

After the plan completes, you should be shown the EC2 instance's public IP as terraform output. You should now be able to connect:

    ssh ubuntu@<public-ip>

### Play around

You can now start playing around with the resources you have created - edit `main.tf` to remove, change or add resources, then run
`terraform apply` to update the actual infrastructure!

All available AWS resources are documented in the [AWS provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

### Understand state

[State](https://developer.hashicorp.com/terraform/language/state) is one of the most important concepts in terraform.

For terraform to know which resources it's supposed to manage, it creates a thing called state. In this example default state is used,
which is just stored on your hard drive - look for `terraform.tfstate` file in this directory.

If you remove this file, terraform will lose track of the resources, and you will need to manage (delete) those by hand :) This
is not straightforward, as there is nothing in AWS that tells you the resources have been create by Terraform, and not all resources
can be tagged!

Locally stored state is great for experimentation. In a production environment, state would be stored somewhere in a cloud (e.g. in S3),
and access would be controlled via locks. 

State can be a source of discrepancies if resources are modified or deleted on the infrastructure by hand, causing state drift.
To deal with these problems, terraform provides an [ability to manage state by hand](https://developer.hashicorp.com/terraform/tutorials/state/state-cli).
Here is a simple example you can run on the CLI:

    terraform state rm aws_subnet.tfexample

Terraform will stop managing that particular resource ("forget" it), and if you run `terraform apply`, it will attempt to recreate it
(and end up failing because of a name clash).

You can bring the resource back into terraform state by looking up the ID, either in AWS Console, or in the terraform output:

    aws_subnet.tfexample: Refreshing state... [id=subnet-034dc30e6c6ed5891]

Import into state:

    terraform import aws_subnet.tfexample subnet-034dc30e6c6ed5891

Run apply again - you should see terraform happy again.

### Cleanup 

After you are done, don't forget to remove:

    terraform destroy

Remove the key pair:

    aws ec2 delete-key-pair --key-name tfexample

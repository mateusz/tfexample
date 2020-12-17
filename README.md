# Terraform example

This example let's you create an AWS EC2 instance you can log in to via SSH.

Document below assumes you know how handle authentication. We reccomend to use aws-vault :)

## Usage

### SSH key

Create an SSH keypair (this cannot be currently created by terraform):

    aws ec2 create-key-pair --key-name tfexample --output text

Copy the private key part and paste it into your, then add it to your ssh agent. On mac:

    pbpaste > ~/.ssh/tfexample
    chmod 600 ~/.ssh/tfexample
    ssh-add ~/.ssh/tfexample

### Vars

Update `terraform.tfvars` to match your key name you have just created in AWS. While you are here, also set your host IP range
(use CIDR ranges such as 1.2.3.4/32), as well as give it a friendly name via name_tag.

You can also [supply those variables in other ways](https://www.terraform.io/docs/configuration/variables.html), if you don't
like locally editing files in version control.

### Create infra

Now you are ready to create resources:

    terraform apply

Review the plan, and confirm with "yes".

### Accessing

After the plan completes, you should be shown the EC2 instance's public IP as terraform output. You should now be able to connect:

    ssh ubuntu@<public-ip>

### Play around

You can now start playing around with the resources you have created - edit `main.tf` to remove, change or add resources, then run
`terraform apply` to update the actual infrastructure!

### Cleanup 

After you are done, don't forget to remove:

    terraform destroy

## Note on state

[State](https://www.terraform.io/docs/state/index.html) is one of the most important concepts in terraform.

For terraform to know which resources it's supposed to manage, it creates a thing called state. In this example default state is used,
which is just stored on your hard drive - look for `terraform.tfstate` file in this directory.

If you remove this file, terraform will lose track of the resources, and you will need to manage (delete) those by hand :) This
is not straightforward, as there is nothing in AWS that tells you the resources have been create by Terraform, and not all resources
can be tagged!
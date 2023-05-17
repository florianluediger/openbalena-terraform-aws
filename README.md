# Terraform configuration for deploying the OpenBalena server on AWS EC2

## Project setup

You will need a domain that is registered with AWS so the required hosted zone can be configured.
Specify your domain name in the `terraform.tfvars` file and also configure it in the `openbalena-ansible/inventory.yaml` file.
You also need to specify your desired username and password for OpenBalena.


## Setting up the infrastructure

To set up OpenBalena in AWS EC2, make sure that you have the AWS CLI and terraform installed.
You also need to be logged in to your AWS account with your AWS CLI.
You can now execute the following commands to deploy the infrastructure.

```bash
terraform init
terraform apply
```

## Connecting to the EC2 instance via SSH

To connect via ssh, you need to get the SSH private key from the terraform outputs and fix its format.

```bash
terraform output openbalena_ssh_private_key > openbalena.key
sed -i '' -e '1d' openbalena.key
sed -i '' -e '$d' openbalena.key
chmod 400 openbalena.key
```

With this key, you can now connect to the EC2 machine.

```bash
ssh -i openbalena.key ubuntu@$(terraform output -raw openbalena_ssh_host)
```

## Installing OpenBalena using Ansible

To install OpenBalena, you need to have Ansible installed.
You also need to have the openbalena.key file to authenticate at the EC2 instance.
Configure the `openbalena-ansible/inventory.yaml` file with your EC2 host that you can get from the terraform outputs.

After finishing the configuration, you can deploy your ansible playbook.

```bash
ansible-playbook -i openbalena-ansible/inventory.yaml openbalena-ansible/playbook.yaml
```

## Using OpenBalena

For information about using OpenBalena, have a look at their official documentation: https://open-balena-docs.balena.io/getting-started/

To connect to balena, you need to add the balena URL to your local balena configuration file `~/.balenarc.yml`:

```yaml
balenaUrl: 'your-domain-here.com'
```

Now you can use your balena CLI to log in with the credentials you have set in the `inventory.yaml` file.
This enables you to use the balena CLI as usual.

```bash
balena login
balena fleets
```
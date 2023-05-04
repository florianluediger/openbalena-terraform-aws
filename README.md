# Terraform configuration for deploying the OpenBalena server on AWS EC2

## Project setup

You will need a domain that is registered with AWS so the required hosted zone can be configured.
Specify your domain name in the `terraform.tfvars` file and also configure it in the `init.sh` script.
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

## Using OpenBalena

For information about using OpenBalena, have a look at their official documentation: https://open-balena-docs.balena.io/getting-started/

To connect to balena, you need to install the self-signed certificates on your local computer. 
To do this, copy the CA certificate file to your local computer and install it.
You can find further information at: https://open-balena-docs.balena.io/getting-started/#install-self-signed-certificates-on-the-local-machine

```bash
scp -i openbalena.key ubuntu@$(terraform output -raw openbalena_ssh_host):/home/ubuntu/ca.crt ./ca.crt
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt # For MacOS
```

You also need to add the balena URL to your local balena configuration file `~/.balenarc.yml`:

```yaml
balenaUrl: 'your-domain-here.com'
```

Finally, you need to set the environment variable `NODE_EXTRA_CA_CERTS` to point to your ca file:

```bash
export NODE_EXTRA_CA_CERTS=/path/to/ca.crt
```

Now you can use your balena CLI to log in with the credentials you have set in the init.sh script.
This enables you to use the balena CLI as usual.

```bash
balena login
balena fleets
```
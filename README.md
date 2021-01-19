# MenuTime App Infrastructure Config

## **Requirements**

### Using terraform:

- provision an S3 bucket to serve the images
- ensure that read access to the bucket is as secured as possible
- provision an IAM user with access to write to the bucket

#### Using ansible:

- store the IAM user's access key and secret securely as ansible variables
- write a playbook to deliver this credential and other settings to a configuration file for use by the backend application (see sample below)

The playbook runs against localhost and deliver the app config to a temp location.

---

### **Notes**

This app config is likely being deployed to a environment outside of AWS (bare metal, Azure, etc.
Outside of AWS its recommended to [create a REST API as an Amazon S3 proxy in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/integrating-api-with-aws-services-s3.html) secured with by [a Lambda authorizer](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html) using a JSON Web Token. Inside AWS an EC2 Instance Profile that assumes the IAM role with S3 access is the best approach.

Terraform can write files directly so there is an opportunity to optimize the setup by removing Ansible from the workflow.

One of the most difficult parts of IaC is the lack of a local development environment that results in a large feedback loop. Luckily when working with AWS there is an open source tool called `localstack`; a fully functional local AWS cloud stack that runs in Docker.

LocalStack requires specific configuration of the Terraform AWS Provider. Creating separate folders for AWS and LocalStack allows for seamless testing in LocalStack and promotion to AWS. Terraform Providers are defined in their respective folders with each env referencing shared modules.

### **Ideas:**

If the backend is deployed to an instance with a static IP define it as a S3 Bucket Policy Condition.

```
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
```

Ansible can [lookup up secrets stored in AWS Secrets Manager](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_secret_lookup.html) and depending on the infrastructure config, storing secrets in there vs Ansible Vault may be better for compatibility with other systems.

Including support for multiple environments (dev, staging, prod) would be simple by using `terraform.workspace` in variable names.

Adding [terratest](https://terratest.gruntwork.io/) for automated testing ensuring PR's work as expected before getting merged and [checkov](https://www.checkov.io/) for static code analysis of Terraform config enforces company/team guidelines and security practices.

---

### **Local Setup**

#### **Prerequisites**

- _Terraform 0.14.4_

The best way to actively switch Terraform versions when moving between projects is [tfenv](https://github.com/tfutils/tfenv)

```
brew install tfenv
```

- _awslocal_

A thin wrapper around the aws command line interface for use with LocalStack. You can install the [awslocal](https://github.com/localstack/awscli-local) command via pip though I prefer `pipx`

```
pipx install awscli-local
```

- _Docker_

Tested with version 20

- _direnv_ (optional)

An extension for your shell. It augments existing shells with a new feature that can load and unload environment variables depending on the current directory.

Automatically sourcing env vars specific to this repo. This can be skipped but sourcing .envrc manually before running commands will be required.

Before running any commands; from the root dir source local env vars if you haven't installed and configured `direnv`

```
source .envrc
```

#### **Install Variant**

Ensuring you're the right directory, running the correct executables, and passing parameters via environment variables or specific command-line is cumbersome. Instead, all commands are automated within a [Variant](https://github.com/mumoshu/variant/) config similar to a Makefile but written in yaml.

To install the latest version of variant:

```
curl -sL https://raw.githubusercontent.com/variantdev/get/master/get | INSTALL_TO=/usr/local/bin sh
```

---

### **Run | LocalStack**

#### **1. Start LocalStack**

```
chow localstack
```

#### **2. initialize terraform**

```
chow terraform-localstack-init
```

#### **3. apply terraform to localstack**

```
chow terraform-localstack-apply
```

#### **4. run ansible**

```
chow ansible-localstack
```

Review the following files:

```
ansible/vars.yml
ansible/app.conf
```

#### **5. cleanup**

```
chow reset
```

---

### **Run | AWS**

#### **1. initialize terraform**

```
chow terraform-aws-init
```

#### **2. apply terraform to aws**

```
chow terraform-aws-apply
```

#### **3. run ansible**

```
chow ansible-aws
```

Review the following files:

```
ansible/vars.yml
ansible/app.conf
```

#### **4. cleanup**

```
chow terraform-aws-destroy
```

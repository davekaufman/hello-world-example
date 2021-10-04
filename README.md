# Prerequisites / Assumptions
- working installations of
	- `terraform`
	- `bash`
	- `aws` cli
	- `docker`
	- `docker-compose`

  everything herein was developed under WSL2 on windows 10, but there is no
  reason to expect that this will not run/function on any linux, mac *or* windows 10 WSL2 env with those prerequisites available.
- an AWS account, and broad permissions to create/modify/destroy resoures therein, including IAM roles/policies. You are
  expected to understand your own AWS access constraints and choose appropriate account/credentials to apply any terraform from
  this exerice.  Caveat Emptor/Lector/Skeletor.
- correctly-exported-or-otherwise-configured AWS credentials for access to the aforementioned account.  You are expected to
  understand how to securely configure and utilize your own AWS access credentials at the command line for this exercise.
- a pre-existing terraform state location, access to same, and working knowledge of terraform backend configuration.

## Optional, recommended
- git pre-commit hooks for linting are configured with [pre-commit](https://pre-commit.com/).  While not strictly speaking
mandatory, installation of this utility as well as the configured hooks in `.pre-commit.config.yaml` would be effectively
so in actual usage scenarios like ops team development / cicd deployment of this solution.

# Usage
## Configure and apply terraform
1. after checking out the repository, edit `terraform/backend.tf` and populate it with the correct values for your backend
   configuration. If utilizing workspaces for environment separation, ensure that the backend configured is accessible with all
   relevant AWS credentials (as mentioned above, managing AWS access considerations is well outside the scope of this exercise.)
2. After editing `terraform/backend.tf`, create or edit the relevant tfvars files for each environment at
   `terraform/tfvars/ENVIRONMENT.tfvars` - example files are provided for a `dev` and `prod` set of environments, with some
   illustrative differences in variable values.
3. If utilizing workspaces for environment separation, `terraform init` and then create the necessary workspaces in the
   standard `terraform workspace new WORKSPACE_NAME` fashion.  If using workspaces, a recommendation is to tie their names to a
   corresponding tfvars file for ease of reference.
4. `terraform plan -var-file tfvars/ENV.tfvars` (eg: `terraform plan -var-file tfvars/ENV.tfvars`).
5. Once satisfied with the `plan`, apply in similar fashion - either by `terraform apply -var-file tfvars/ENV.tfvars` or if you
   chose to write out a planfile in the previous step, `terraform apply PLANFILE`

After the apply is complete, the result will be a new VPC, ECS cluster and service (running on AWS Fargate), a new ECR
repository associated with the new service, as well as optional hosted zone and DNS alias for the load balancer, optional ACM
certificate for optional https ALB listener.
The service at this point will be non-functional, because you have not yet created/deployed the relevant artifact (docker
container) to the new ECR repo.

The URL for the publicly-available load balancer will be located at either https://APP_NAME.HOSTED.ZONE or
http://DNS-NAME-OF-AWS.LOAD.BALANCER
You are expected to be able to determine the former yourself (if you so-chose to create the route53 hosted zone), whereas the latter can be located in the terraform `output` as `lb_dns`

## deploy / update container
after successfully applying the terraform in the previous section, and with appropriate AWS credentials still available in your shell,

1. cd to the `src` directory
2. Edit the `Dockerfile` in this directory and update the `MAINTAINER` line near the top.
3. in the same directory, run `deploy.sh -h` to see detailed usage information.
4. Follow the usage information to build and deploy an updated container to ECR.


## local development
The `hello-world` python script test app is creatively located in the `src` as `hello-world.py`
Also located in the `src` directory is the relevant `Dockerfile` and `docker-compose.yml` that define the `hello-world` container
and a simple compose stack to replicate the aws setup locally.
1. to bring up the stack from scratch, or to test changes, run the expected `docker-compose build` and `docker-compose up -d` combination.
2. to bring the stack down, `docker-compose down`

Once the compose stack is up, you can access the hello-world service via the stack's nginx proxy at
[http://localhost](http://localhost), or (for
local development only of course) you can access the underlying backend container at [http://localhost:3000](http://localhost:3000)
You can also `curl -H "Host: hello-world.local` to see the proxy is truly proxying requests to the backend container.


# Public code utilized
- [nginx-proxy/nginx-proxy](https://github.com/nginx-proxy/nginx-proxy)  Public nginx proxy docker container, used in the local
  `docker-compose` stack to replicate proxied access to the backend container
- as per the note in `module/hello-world/vpc` I deliberately chose ***not*** to use publicly available terraform modules like the aws or S3 bucket modules, in order to demonstrate a thorough understanding of the underlying AWS configuration and prerequisites. In production usage, unless there was good cause not to (such as external auditing requirements, for example) we would likely want to leverage these community-developed modules where appropriate, as well as restructure the code to accomodate the previously-mentioned more mature layered/remote-state-reference-driven architecture.

Test Ami with Terraform
=======================

Test AMI's 
----------

| Date          | AMI Id                    | Code Deployment       | Cloud Init                            | Build                 | OS            |  
| ------------- | ------------------------- | --------------------- | ------------------------------------- | --------------------- | ------------- |
| 2025/01/01    | ami-blahblahblahblah1     | N/A                   | cloud-init.example-ecs.yml            | General-0.0.1         | ubuntu:16.04
| 2025/01/01    | ami-blahblahblahblah2     | N/A                   | cloud-init.example-nginx-php56.yml    | PHP5.6/NGINX-0.0.1    | ubuntu:16.04
| 2025/01/01    | ami-blahblahblahblah3     | N/A                   | cloud-init.example-apache-php56.yml   | PHP5.6/Apache-0.0.1   | ubuntu:16.04
 
#### Change to required Terraform Version
> NOTE: Need to re-test these against newer versions of Terraform.
```commandline
chtf 1.12
```

#### Make commands (includes local.ini support)
```commandline
make init
make init-upgrade
make config
make plan 
make apply
make documentation
make destroy-plan
make destroy
```
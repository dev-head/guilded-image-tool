Docker 
======

Description
-----------
The Packer Docker build configurations are used to generate production ready docker images. These can be built locally for development and testing; as well as deploying to production ECR. 

**This effort is to provide the following:** 
* Standardized Docker Images. 
* Repeatable Docker Images.
* Reduced Development effort to configure and use. 
* Reduced time it takes to go to production. 
* Reduced security footprint by allowing a single public channel into the ecosystem. 
* Manage Patches automatically and efficiently. 
* Automate ECR deployment images. 

Note
----
* You must first create an ECR repo to match any new builds before you deploy to ECR; AWS doesn't like to make things easy. 

Docker Images Documentation
---------------------------
These are the current Docker Images available, click to check out their documentation. 
* [bootstrap](../docker/bootstrap/README.md)
* [base](../docker/base/README.md)
* [base_app](../docker/base_app/README.md)
* [golang](../docker/golang/README.md)
* [php](../docker/php/README.md/)


Docker Image Hierarchy
----------------------
We have created the following hierarchy to allow for more flexible images and provide for a greater separation of concerns.

| Image         | Parent    |
| ------------- | --------- | 
| bootsrap      | Community |
| base          | bootstrap |
| base_app      | base      |
| php*          | base_app  | 
| golang*       | base_app  |    


Working with ECR Images in your project
---------------------------------------
For deployments we typically create a custom docker file named `Dockerfile.deploy`; which is used to ensure a consistent deployment process and keep it separate from development processes, while still being available if needed.
This image is built from a provisioned `example.com` ECR repository; allowing for a consistent and secured image in production. In order to build this image, you'll need to log into ECR. 

#### Log into ECR
> Once you log into ECR, it's a valid token for 12 Hours. 
```commandline
eval $(aws ecr get-login  --no-include-email --region us-east-1 || true)
``` 

#### Current Tags applied to ECR 
* ubuntu-16.04
* pv0.0.1-ubuntu-16.04 (indicates which provisioned version it came from.)

#### Current ECR Images 
> We prefix packer ECR images with `examplecom-` to denote they are official production images. These images can be leveraged in your applications.
* [bootstrap](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-bootstrap:ubuntu-16.04)
* [base](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-base:ubuntu-16.04)
* [base_app](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-base:ubuntu-16.04)
* [php7.3 Nginx](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-php7.2-nginx:ubuntu-16.04)
* [php7.3 Nginx](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-php7.3-nginx:ubuntu-16.04)
* [php7.3 Apache](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-php7.2-apache:ubuntu-16.04)
* [golang1.2 Nginx](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-golang1.2-nginx:ubuntu-16.04)


Build :: Local
--------------
> You must build each image locally so they can reference their respective parents. 
```commandline
packer build -only=local -var-file docker/bootstrap/ubuntu-16.04/config.json docker/bootstrap/ubuntu-16.04/docker-build.json 
packer build -only=local -var-file docker/base/ubuntu-16.04/config.json docker/base/ubuntu-16.04/docker-build.json 
packer build -only=local -var-file docker/base_app/ubuntu-16.04/config.json docker/base_app/ubuntu-16.04/docker-build.json 
packer build -only=local -var-file docker/php/php7.2+nginx+ubuntu-16.04/config.json docker/php/php7.2+nginx+ubuntu-16.04/docker-build.json
packer build -only=local -var-file docker/php/php7.3+nginx+ubuntu-16.04/config.json docker/php/php7.3+nginx+ubuntu-16.04/docker-build.json
packer build -only=local -var-file docker/golang/golang1.12+nginx+ubuntu-16.04/config.json docker/golang/golang1.12+nginx+ubuntu-16.04/docker-build.json 
packer build -only=local -var-file docker/php/php7.2+apache+ubuntu-16.04/config.json docker/php/php7.2+apache+ubuntu-16.04/docker-build.json 
```

#### run local images.
```
docker run -it --rm examplecom-bootstrap:ubuntu-16.04
docker run -it --rm examplecom-base:ubuntu-16.04
docker run -it --rm examplecom-base_app:ubuntu-16.04
docker run -it --rm examplecom-php7.2-nginx:ubuntu-16.04
docker run -it --rm examplecom-php7.3-nginx:ubuntu-16.04
docker run -d --rm --publish 81:80 examplecom-php7.2-apache:ubuntu-16.04

```

Build :: ECR
------------
> NOTE: update the provisioned_version variable to increment the builds; 
> Failing to update that varaible will cause the previous version to be deleted.
> it's purpose is to allow an internal build number to roll back to if needed. 
```commandline
packer build -only=ecr -var-file docker/bootstrap/ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/bootstrap/ubuntu-16.04/docker-build.json 

packer build -only=ecr -var-file docker/base/ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/base/ubuntu-16.04/docker-build.json
    
packer build -only=ecr -var-file docker/base_app/ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/base_app/ubuntu-16.04/docker-build.json     

packer build -only=ecr -var-file docker/php/php7.2+nginx+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/php/php7.2+nginx+ubuntu-16.04/docker-build.json

packer build -only=ecr -var-file docker/php/php7.3+nginx+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/php/php7.3+nginx+ubuntu-16.04/docker-build.json

packer build -only=ecr -var-file docker/golang/golang1.12+nginx+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/golang/golang1.12+nginx+ubuntu-16.04/docker-build.json 

packer build -only=ecr -var-file docker/php/php7.2+apache+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/php/php7.2+apache+ubuntu-16.04/docker-build.json
```

How this all works
------------------
Due to significant shortcomings of Packer currently this is more in a proof of concept phase on how this works. That being said lets break it down so it makes a bit more sense. Each docker image type is in the `docker/` directory and consists of at least the following files/dirs: 
* `root/` 
    * This directory is mapped to the docker image `/`, any file or directory you place in there will override what is in the docker image using `rsync`, which ensures you won't delete a directory. 
    * This is used to allow a consistent method to mount files into the container from this local directory. 
    * This is typically where you'll add in configurations or any other file you need to import into the image. 
* `config.json`
    * This file is passed into the packer command and contains the specific build information that makes it different than the rest. 
    * The exception here is with `changes`, currently packer can't translate them so we hard code them in `docker-build.json` file until we move to the next phase. 
* `docker-build.json`
    * This file is used to define the build stages that are available `local` and `ecr`. 
    * This file is also hard coding the Docker `changes` configuration. 
    * There is a unique file for each docker image to support the hard coded `changes` set. 
* `provision.sh`
    * This bash script is the main entrypoint for provisioning the Docker image. 
    * These provisioning scripts should follow the existing ones and ensure they `build.init.sh` and `build.exit.sh` to keep the images clean and devoid of extra size.     

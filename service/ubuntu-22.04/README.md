Ubuntu 22.04
============
Builds a generic ami for ubuntu:22.04 image, patched and secured

AMI's
-----
| Account           | OS        | Version   | AMI Id                    | Created Date  | Provision | Use Case   |
|:-----------------:|:---------:|:---------:|:-------------------------:|:-------------:|:---------:|:----------:|

Environment 
----------
* **local:** builds a local docker image for basic testing
* **prod:**  builds an image using packer and pushes it to AWS (ensure you delete image and EBS snapshot if image is no good) 

Build / Test Locally
--------------------
```commandline
packer build -only=local -var-file service/ubuntu-22.04/v0.0.1/config.example.json \
   -var 'aws_profile=ExampleNamedProfile' -var 'provision_version=0.0.1' \
   service/ubuntu-22.04/v0.0.1/packer-template.json

docker run \
  -it --rm --privileged=true \
  --entrypoint /bin/bash \
  exco/ubuntu:22.04-0.0.1
```

 Build AWS [example]
-------------------
```commandline
packer build -only=prod -var-file service/ubuntu-22.04/v0.0.1/config.example.json \
    -var 'aws_profile=ExampleNamedProfile' -var 'provision_version=0.0.1' \
    service/ubuntu-22.04/v0.0.1/packer-template.json
```
 
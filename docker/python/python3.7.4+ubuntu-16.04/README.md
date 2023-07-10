Docker Image for [python]::[3.7.4]::[ubuntu]
====================================================

Description
-----------
Image used for hosting python service. There are two pipelines, `local` and `ecr`; local is used for testing and ecr host production images. 

* [Image](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-python3.7.4:ubuntu-16.04)
* [Docker Example/Default](example/default)

Docker Environment & Arguments 
------------------------------
| Variable  | Required  | Default           | Env   | Arg   | 
| --------- | --------- | ----------------- | ----- | ----- | 



Build :: Local 
--------------
```commandline
packer build -only=local -var-file docker/python/python3.7.4+ubuntu-16.04/config.json \
    docker/python/python3.7.4+ubuntu-16.04/docker-build.json
```

Test :: Local Image
-------------------
```commandline
docker run -d --rm --publish 81:80 examplecom-python3.7.4:ubuntu-16.04
```

ECR
----

#### Build and Deploy to ECR [Production]
```commandline
packer build -only=ecr -var-file docker/python/python3.7.4+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/python/python3.7.4+ubuntu-16.04/docker-build.json    
```

#### Test ECR [Production] Locally
```commandline
docker run -d --rm --publish 81:80 555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-python3.7.4:ubuntu-16.04
```
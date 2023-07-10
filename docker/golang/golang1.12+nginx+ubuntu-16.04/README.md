Docker Image for [Golang]::[1.2]::[nginx]::[ubuntu]
====================================================

Description
-----------
Image used for hosting golang web service. There are two pipelines, `local` and `ecr`; local is used for testing and ecr is where we host production images. 

* [Image](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-golang1.2-nginx:ubuntu-16.04)
* [Docker Example/Default](example/default)

Docker Environment & Arguments 
------------------------------
| Variable  | Required  | Default           | Env   | Arg   | 
| --------- | --------- | ----------------- | ----- | ----- | 
| GOPATH    | No        | /go               | Yes   | Yes   |
| GOCACHE   | No        | ${GOPATH}/cache   | Yes   | No    |


Build :: Local 
--------------
```commandline
packer build -only=local -var-file docker/golang/golang1.12+nginx+ubuntu-16.04/config.json \
    docker/golang/golang1.12+nginx+ubuntu-16.04/docker-build.json
```

Test :: Local Image
-------------------
```commandline
docker run -d --rm --publish 81:80 examplecom-golang1.2-nginx:ubuntu-16.04
```

ECR
----

#### Build and Deploy to ECR [Production]
```commandline
packer build -only=ecr -var-file docker/golang/golang1.12+nginx+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/golang/golang1.12+nginx+ubuntu-16.04/docker-build.json    
```

#### Test ECR [Production] Locally
```commandline
docker run -d --rm --publish 81:80 555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-golang1.2-nginx:ubuntu-16.04
```
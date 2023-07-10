Docker Image for: [PHP]::[7.3]::[nginx]::[ubuntu]
====================================================

Description
-----------
Image used for hosting a php web service. 

* [Image](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-php7.3-nginx:ubuntu-16.04)


Docker Environment Variables 
----------------------------
| Variable  | Required  | Default       |
| --------- | --------- | ------------- | 

Build :: Local 
--------------
```commandline
packer build -only=local -var-file docker/php/php7.3+nginx+ubuntu-16.04/config.json \
    docker/php/php7.3+nginx+ubuntu-16.04/docker-build.json 

```

Test :: Local
-------------
```commandline
docker run -d --rm --publish 81:80 examplecom-php7.3-nginx:ubuntu-16.04
```


Build :: ECR
------------
```commandline
packer build -only=ecr -var-file docker/php/php7.3+nginx+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/php/php7.3+nginx+ubuntu-16.04/docker-build.json
```

Test :: ECR 
-----------
```commandline
cd docker/php/php7.3+nginx+ubuntu-16.04
docker build -t packer:test-php7.3-nginx-ubuntu -f Dockerfile .
docker run -d --rm packer:test-php7.3-nginx-ubuntu
```


```commandline
docker kill test_php; \
    docker build -t packer:test-php7.3-nginx-ubuntu -f Dockerfile .; \
    docker run --name test_php -d --rm -v ${PWD}/test:/test packer:test-php7.3-nginx-ubuntu ; \
    docker logs -f test_php 
```


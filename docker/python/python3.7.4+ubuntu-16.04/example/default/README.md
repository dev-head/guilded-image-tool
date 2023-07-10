Example [Default] :: [python]
=============================

Description
-----------
This is an example of a basic python service.There are two docker files used here to test against the local image, used for testing before going to ECR; the ECR Dockerfile is used to run tests against the production image.  

### Working Directory
```commandline
cd docker/python/python3.7.4+ubuntu-16.04/example/default
```

#### Build Local Example Image 
```commandline
docker build -t packer-local:test-python3.7.4-ubuntu -f Dockerfile .
```

#### Build ECR Example Image 
```commandline
docker build -t packer-ecr:test-python3.7.4-ubuntu -f Dockerfile.ecr .
```

#### Run The Built Example Image (Background)
```commandline
docker run -d --rm --name "example-default" packer-local:test-python3.7.4-ubuntu
docker logs -f example-default
docker stop example-default
```

#### Tests 
```commandline
docker exec -it example-default which python
docker exec -it example-default python --version
```

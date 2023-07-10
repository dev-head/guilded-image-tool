Ubuntu 16.04 :: BASE
====================
Builds a "golden" generic Ubuntu 16.04 ami based off latest Ubuntu image, patched and secured. Defaults to provision_version 0.0.1 (to support legacy needs)


Environment 
----------
* **local:** builds a local docker image for basic testing
* **prod:**  builds an image using packer and pushes it to AWS (ensure you delete image and EBS snapshot if image is no good) 

Provisioner 
----------- 

**\***Need to add code to restart codedeploy and add to init.d when using provision version 0.0.1 ami such as**

```- path: /sbin/enable_codedeploy
    permissions: '0700'
    content: |
      #!/bin/bash
      #
      # This script is used to re-enable and start the codedeploy agent at end of cloud-init
      #
      update-rc.d codedeploy-agent defaults
      service codedeploy-agent start
``` 
     

Build / Test Locally
--------------------
```commandline
packer build -only=local -var-file service/ubuntu-16.04/v0.0.1/config.example.json \
    -var 'provision_version=0.0.1' service/ubuntu-16.04/v0.0.1/packer-template.json

docker run \
  -it --rm --privileged=true \
  --entrypoint /bin/bash \
  exco/ubuntu:16.04-0.0.1
```

Build AWS [example] 
-------------------
```commandline
packer build -only=prod -var-file service/ubuntu-16.04/v0.0.1/config.example.json \
    -var 'provision_version=0.0.1' service/ubuntu-16.04/v0.0.1/packer-template.json
```

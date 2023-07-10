AWS Machine Image (AMI)
=======================

Description
-----------
[Packer] is used to provide a standard process for creating repeatable images that are used for hosting and development of services. Refer to their online [documentation] for references. [Packer] will save meta data for the builds in their system which we can leverage through other apps, sharing or reference. You should **never** place any account credentials into a server when possible. With [Packer] we describe and dictate what goes into each image, weather it's specific for a service or it's going to be leveraged in a more general way, we control this through one interface. 

Status
------
This repo is still just a baby taking small steps and hitting it's head on the edge of the coffee table and as patterns emerge we shall improve.

NOTE
----
> using your aws credentials with a profile is not working, make sure you're using the correct key. 

Golden Images
-------------
> These are base ami's for us to use in production, that come configured with defaults including trendmicro install and cloudwatch metrics/logs config.
> We have different provisioner versions, please see provisioner section for more details 


Links
-----
[Packer]:http://packer.io
[documentation]:https://www.packer.io/docs
[download]:https://www.packer.io/downloads.html
[github]:https://github.com/mitchellh/packer
[atlas service]:https://atlas.hashicorp.com
[no support]:https://github.com/mitchellh/packer/issues/869

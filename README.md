As per referenced requirements in diagram, I created the required services in AWS environment.
Additional explanation:
Even it wasn't stated in the request, I created highly available (DR solution ) and we have option to deploy services in 2 deferent regions (environments: dev and prod).
With security in consideration, i also deployed VPC endpoint S3 Gateway for secure communication between ec2 instances and S3 bucket.
Also, in every module there is additional services (features) that can be deployed (they are highlighted at the moment).
In order to deploy them (since still passing variable and outputs between modules and services is not perfect), fist we deploy current infrastructure and then we can update variables and deploy highlighted services.

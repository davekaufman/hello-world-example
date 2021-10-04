# Notes about the problem and solution as implemented
- in an actual deployment, creation of the foundational aspects (VPC/subnets/routes) along with
  not-even-considered-in-this-exercise complexities like VPN config, customer gateway config, transit gateway and/or vpc peering
  needs, etc... would all be created in a separate layer of terraform, and the relevant resources referenced via terraform
  remote state.  As this is a much more advanced deployment strategy - and heavily informed by the environment/needs of the org
  which will undertake its implementation - I simplified creation of all AWS resources in one reusable terraform module.

- an artifact of that simplification is that certain global resources (like IAM) are not uniquely named, which fundamentally
  means that this solution expects to be the only deployment _within a given AWS account_ - that is, that deploying this in dev
  vs. staging. vs. prod, each of those is its own account.  This seems fine for this exercise, but for a more mature deployemnt
  (see previous bullet) this restriction may or may not exist.  Nevertheless, as environment-mapping-to-account is a reasonable
  best practice (and admittedly for simplicity's sake) I did not undertake the additional complexity of deploying multiple
  environments within a single AWS account.

- for the sake of this exercise, it is assumed that the container to be deployed/used within ECS will carry the 'latest' tag.
  This is not recommended for production use, as image tag creation and management is complex and largely the job of a
  corresponding CICD build pipeline that lies outside the scope of this exercise.

- improving the wrapper script to intelligently manage the terraorm backend configuration is a natural next step iteration.

- cloudwatch alerting for insufficient tasks / problems placing ECS tasks would be desired were this an actual deployemnt.

- of course, the "hello-world" service used in this example bears only passing resemblence to a real service - it emits no
  service-specific metrics, for example.  Deployment of a more fully-realized microservice would come with monitoring
  considerations around key metrics that this simple "hello-world" demonstration is not sufficient to exemplify.

- the `docker-compose` solution for local development/testing could be made more featureful, depending on development needs and
  existing architectural features, eg: an extant internal CA to issue certs against for inclusion in the local artifacts for testing https without the
  hassle of self-signed certs.

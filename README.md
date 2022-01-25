# LW Agent + AWS Fargate Guide <!-- omit in toc -->

[![Git](https://app.soluble.cloud/api/v1/public/badges/171a7a9a-c3cb-454d-b292-f4dc08298324.svg?orgId=680721565643)](https://app.soluble.cloud/repos/details/github.com/andrewdanglacework/fargate-ecs-guide?orgId=680721565643)  
# LW Agent + AWS Fargate Guide <!-- omit in toc -->
**September 2021**

### Contents
- [Change Log :notebook:](#change-log-notebook)
- [Overview](#overview)
- [Best Practices](#best-practices)
- [Requirements](#requirements)
- [Installation Steps](#installation-steps)
- [Got Feedback?](#got-feedback)

## Change Log :notebook: 
#### October 2021 - What's coming? <!-- omit in toc -->
* Stay Tuned! 

#### September 2021 - What's new? <!-- omit in toc -->
* We're embracing docker's multi-stage build feature when baking the agent.
* Updated best practices to include 1 Agent Token : 1 Service recommendation
* Updated one-liner and corresponding entrypoint to start the agent service
* Updated side-car reqs
* We now have tons of example dockerfiles & helper scripts. :star_struck: See [/examples](/examples)

#### August 2021  <!-- omit in toc -->
* Initial public release for this guide :)
* Thank you to all the amazing Lacers who providing valuable feedback!

## Overview

Two options are available when installing the LW Agent in AWS Fargate. Both are presented below. We highly recommend the "baking" solution as it pre-installs and configures the agent _directly_ in the Docker Image.

## Best Practices

* Install the Agent _directly_ into your existing application Dockerfile(s):
    * Use [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds).
    * Securely pass in the LW Agent Token when building the Docker image. This may be achieved by putting the token in the container definition as an environment variable.
* Allocate 512MB vCPU and 1GB RAM for the LW Agent.
* Use one LW Agent Token per _container_ (`TaskDefinition` Service).

## Requirements

* The base image in your Dockerfile must be based on one of the Linux distros found [here](https://support.lacework.com/hc/en-us/articles/360005230014). 
* As the LW Agent user gathers network packet data, it needs to be run with <code>sudo</code></strong> privileges. The LW Agent must be run as <strong><code>root</code></strong>
* Have valid Access Token(s) for the LW Agent(s). These may be obtained at via the [LW CLI](https://github.com/lacework/go-sdk/wiki/CLI-Documentation#agent-access-token-management) (see [Installing the CLI & Creating a Token](/examples/cliToken.sh) bash script for a simple example) or, alternatively, head over to <code>[https://](https://YOUR-ORG.lacework.net/ui/investigation/settings)<strong><span style="text-decoration:underline;">YOUR-ORG[.lacework.net/ui/investigation/settings](https://YOUR-ORG.lacework.net/ui/investigation/settings)</span></strong>  </code>
* IAM User used needs permissions listed in [AmazonECSTaskExecutionRolePolicy](https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy$jsonEditor)
* LW Agent needs to reach Lacework’s API endpoint.  Default: [https://api.lacework.net](https://api.lacework.net). See [here](https://support.lacework.com/hc/en-us/articles/1500007918841-Agent-Server-URL) for other endpoints.
* If leveraging the sidecar alternative, be sure to review [additional requirements](/examples/sidecar/README.md#additional-requirements).

## Installation Steps 

Two major options to install the LW Agent in AWS Fargate are available. The *preferred* method is to backe the LW Agent directly in the Docker Image. We encourgae the use of multi stage builds but a verion sans multi-stage builds is also documented below:

***TO VIEW THE INSTALLATION STEPS, NAVIGATE TO THE CORRESPOINDING CONFIGURATION FROM BELOW***

- [*Recommended* Baked in the Docker Image WITH multi-stage builds](examples/baked-multistageRECOMMENDED/README.md)
- [Baked in the Docker Image SANS multi-build](examples/baked-github-build/README.md)
- [Using a Sidecar](examples/sidecar/README.md)

## Got Feedback?

- Please submit a PR
- Email `diana@lacework.com`

# Baking the LW Agent into existing Dockerfile **sans** Multi-Stage Build

This option downloads our latest LW Agent from the [GitHub Release repository](https://github.com/lacework/lacework-agent-releases). The installation script will determine the underlying OS and install the appropriate package. 

Notes:
* The <code>RUN</code></strong> command uses [BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) to securely pass the LW Agent Token as <code>LW_AGENT_ACCESS_TOKEN</code>. This is not necessary but <strong>recommended</strong>. For an example <em>sans</em> the BuildKit see the [/sans-buildki-example](/examples/baked-github-build/sans-buildkit-example/README.md).
* <strong>Additional Requirement: </strong>You must be able to install `curl`, `openssl`, and `ca-certificates`, if they are not already included in the base image.  The example provided in this document is Ubuntu.  You will need to first determine the Linux distro used by your base image, identify the package manager used by that distro, and install the needed dependencies as part of your <code>Dockerfile</code>.
* The below command may be appended to an existing `RUN` command via `&&`’s. Alternatively, it may be added as a new `RUN` command.

## Installation Steps 

### Step 0: Review [Best Practices](../../README.md#best-practices) & [General Requirements](../../README.md#requirements)


### Step 1: Copy One-Liner & edit entrypoint script

#### One-liner RUN command (with BuildKit)

```Dockerfile
RUN --mount=type=secret,id=LW_AGENT_ACCESS_TOKEN for asset_url in $(curl -s https://api.github.com/repos/lacework/lacework-agent-releases/releases/latest | jq --raw-output '.assets[]."browser_download_url"'); do \
    curl -OL ${asset_url}; done && \
    md5sum -c checksum.txt      && \
    lwagent=$(cat checksum.txt | cut -d' ' -f3) && \
    tar zxf $lwagent -C /tmp    && \
    cd /tmp/${lwagent%.*}       && \
    mkdir -p /var/lib/lacework/config/          && \
    echo '{"tokens": {"accesstoken": "'$( cat /run/secrets/LW_AGENT_ACCESS_TOKEN)'"}}' > /var/lib/lacework/config/config.json            && \
    sh install.sh      && \
    cd ~               && \
    rm -rf /tmp/${lwagent%.*}
```

#### Full Example 

[Existing Dockerfile](baked.dockerfile)

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
   curl \
   jq \
   sed \
   && rm -rf /var/lib/apt/lists/*
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

##
## add the above one-liner RUN command to bake in the LW Agent here:) 
##

ENTRYPOINT [ "/docker-entrypoint.sh" ]
```

[docker-entrypoint.sh](docker-entrypoint.sh)

```bash
#!/bin/sh

##
## starting the LW Agent
service datacollector start
##
curl -s  https://stream.wikimedia.org/v2/stream/recentchange |   grep data |  sed 's/^data: //g' |  jq -rc 'with_entries(if .key == "$schema" then .key = "schema" else . end)'
```


### Step 2: [Build](build-baked.sh)  & [Push](push-baked.sh)

```bash
# Set variables for ECR
export AWS_ECR_REGION="us-east-2"
export AWS_ECR_URI="000000000000.dkr.ecr.us-east-2.amazonaws.com"
export AWS_ECR_NAME="dianademo"

# Store the LW Agent Token in a file (See Requirements to obtain one)
echo "ae83fc1d3f79f8f84b3512688b5b6b98f33f6688fa4c67931afae9a6" > token.key

# Build and Tag the image
DOCKER_BUILDKIT=1 docker build --secret id=LW_AGENT_ACCESS_TOKEN,src=token.key --force-rm=true --tag "${AWS_ECR_URI}/${AWS_ECR_NAME}:latest-baked" .

# Log in to ECR and Push the image
aws ecr get-login-password --region ${AWS_ECR_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_URI}
docker push "${AWS_ECR_URI}/${AWS_ECR_NAME}:latest-baked"
```

### Step 3: Run  

To run the image, AWS requires the configuration of an ECS [Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html). A very simple example is [here](taskDefinition.json). For more examples, visit the [AWS documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/example_task_definitions.html).

```bash
# Create a cluster. You only need to do this once.
aws ecs create-cluster --cluster-name dianademo-cluster 

# Register the task definition
aws ecs register-task-definition --cli-input-json file://taskDefinition.json   
```

The next step is to either create a service or simply run the task. Below we create a service through the AWS web console and also present the <code>json</code></strong> output of the service [here](service.json) for reference. 

```bash
# Create a Service (or Run Task) 
## Follow the AWS Wizard
open https://us-east-2.console.aws.amazon.com/ecs/home?region=us-east-2#/clusters/dianademo-cluster/createService 

## OR provide json definition of the service
aws ecs create-service --cli-input-json file://service.json   

# View Service
aws ecs list-services --cluster dianademo-cluster 
```
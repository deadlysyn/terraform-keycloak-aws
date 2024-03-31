# Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Workflow](#workflow)
- [Monitoring](#monitoring)
- [Opinions](#opinions)
- [TODO](#todo)
- [Dependencies](#dependencies)
- [References](#references)
- [FAQ](#FAQ)

## Introduction

**NOTE:** I spin releases for the latest Keycloak versions avoiding "dot ohs"
e.g. 15.1.1+ but not 15.1.0.

Opinionated infrastructure and deployment automation for Keycloak.

- Batteries included (network plumbing + container build/deploy) 🚀
- Tested with latest Terraform 😍
- Prefer fully-managed backing services (Fargate, Aurora, CloudWatch) 🥱
- JDBC clustering and cache replication (improved HA) 🤙

![Logical Diagram](https://raw.githubusercontent.com/deadlysyn/terraform-keycloak-aws/main/assets/keycloak.png "Logical Diagram")

**NOTE:** The diagram shows the default self-contained publicly-accessible service
leveraging the included
[network module](https://github.com/deadlysyn/terraform-keycloak-aws/tree/main/modules/network).
You can also deploy an internal service (no Internet connectivity) or public
service that uses your own network infrastructure. See
[terraform.tfvars](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/environments/template/terraform.tfvars)
for examples of how to select the right approach for your needs. When deploying
to your own network infrastructure, read over the network module to understand
how to configure network components.

Psst: [Need IaC for your Keycloak clients?](https://github.com/deadlysyn/keycloakinator)

## Prerequisites

- [aws v2 CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- Docker (container build/deploy)
- UNIX-like OS (tested on Linux and MacOS)

## Workflow

The basic workflow relies on make to reduce typing toil.
If you are just getting started, refer to
[the bootstrapping guide](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/docs/bootstrapping.md).

```console
# Create new environment
$ cd environments
$ ./mkenv -e <env_name>
$ cd <env_name>
$ make all

# Update existing environment
$ cd environments/<env_name>
$ vi terraform.tfvars # edit as needed...
$ make update

# Destroy environment
$ cd environments/<env_name>
$ make destroy
# type 'yes' to confirm

# Build Keycloak container and deploy
$ cd build
$ make all ENV=<env_name>
```

## Monitoring

Since monitoring approaches vary, I've avoided codifying monitoring-specific opinions
to avoid adding cost and complexity. In combination with external synthetics and
metrics, you may want to extend this with sidecar containers to provide enhanced monitoring.
[An example of how to do that with Datadog](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/modules/keycloak/templates/container_definition_datadog.json)
is included for reference. When adding sidecars, you will need to adjust CPU and
memory reservations appropriately. For Datadog, you need to reserve an additional
256 CPU units and 512MB of memory.

## Opinions

Similar to popular frameworks, bootstrap time is reduced by encapsulating technical opinions.
This gets functional infrastructure online quickly and consistently.
However, you can easily adjust these as needed. This section calls out key
design choices.

### Don't Re-Invent the Wheel

The Keycloak module itself wraps only a few AWS Terraform primitives, preferring
trusted registry modules. Avoiding bespoke solutions where community-tested options
exist improves quality and reduces maintenance overhead.

We have contributed to many of these modules ourselves, and leverage them for
production infrastructure. We've taken the time to read the module source,
understand how they work, and reason about the choices they've made.
You should do the same. Dependencies are conveniently linked in
[References](https://github.com/deadlysyn/terraform-keycloak-aws#references).

### An Exception to Every Rule

While there are a number of modules to create AWS network resources, networking
is an exception to the re-use rule above. The provided network module
is simplistic, but adequate and easy to adjust based on your requirements.

It is meant to serve two purposes: a starting point to get new environments
online quickly, and interface documentation. Taking it's outputs as an example, you
can easily provide similar inputs via configuration from existing infrastructure or
a module of your choice.

### Encrypt Everything

Whether ALB listeners, ECR, RDS, or remote state... anything that can have encryption
enabled does by default. Aside from belief in the cypherpunk motto,
this is due to the fact Keycloak is a security service.

The one exception today is intra-VPC traffic between the ALB and ECS containers.
Fixing this so service traffic is FULLY encrypted is on the TODO list (PRs welcome).

Aside from just "turning it on", thought is being given to cert management,
workflow, etc. For example, a sidecar proxy integrated with Let's Encrypt
would be more up-front complexity but not require updating container trust
stores, worrying about renewals, etc.

### Reduce Cognitive Load

Upstream defaults are used when sensible. Settings unlikely to change in the typical
case have local defaults or are hard-coded (e.g. DB port number). The goal is to reduce
cognitive load, but these are only opinions that you can override.

The included
[standalone-ha.xml](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/build/keycloak/standalone-ha.xml)
and
[docker-entrypoint.sh](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/build/keycloak/docker-entrypoint.sh)
have been adjusted to work with ECS out of the box. These should generally suffice,
but may need adjusted based on your requirements.
You might also want to toggle different feature flags, which
are controlled in
[profile.properties](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/build/keycloak/profile.properties).

## TODO

- Terratests
- ALB -> ECS TLS
- Performance test automation + baseline
- Multi-region support
- MySQL support

## Dependencies

- https://github.com/cloudposse/terraform-aws-tfstate-backend
- https://github.com/cloudposse/terraform-null-label
- https://github.com/cloudposse/terraform-aws-alb
- https://github.com/cloudposse/terraform-aws-ecs-alb-service-task
- https://github.com/cloudposse/terraform-aws-ecr
- https://github.com/cloudposse/terraform-aws-rds-cluster

## References

- https://hub.docker.com/r/jboss/keycloak
- https://www.keycloak.org/docs/latest/server_installation/index.html
- https://www.keycloak.org/docs/latest/upgrading/index.html
- https://docs.datadoghq.com/integrations/ecs_fargate
- https://docs.datadoghq.com/integrations/faq/integration-setup-ecs-fargate
- https://docs.datadoghq.com/agent/guide/autodiscovery-with-jmx

Abandon hope all ye who enter here... :-)

- https://www.keycloak.org/docs/latest/server_installation/index.html#_clustering
- https://infinispan.org/docs/stable/index.html
- https://www.keycloak.org/2019/05/keycloak-cluster-setup.html
- https://www.keycloak.org/2019/08/keycloak-jdbc-ping
- http://jgroups.org/manual/#JDBC_PING
- https://octopus.com/blog/wildfly-jdbc-ping

## FAQ

Q: `The target group with targetGroupArn <arn> does not have an associated load balancer.`

A: This is rare, but if it happens to you just re-run `make all` (double apply), perhaps waiting a few minutes in between.

Q: How do I get support?

A: Open GitHub issues. If there's a bug you know how to fix, also open a PR and link it in your issue.

# Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Workflow](#workflow)
- [Monitoring](#monitoring)
- [Strong Opinions Weakly Held](#strong-opinions-weakly-held)
- [TODO](#todo)
- [Dependencies](#dependencies)
- [References](#references)

## Introduction

Opinionated infrastructure and deployment automation for Keycloak.

- Batteries included (network plumbing + container build/deploy) 🚀
- Tested with latest Terraform (<= v0.13 currently required while upstream modules are updated) 😍
- Prefer fully-managed backing services (Fargate, Aurora, CloudWatch) 🥱
- Latest Keycloak (11.0.3) 😎
- JDBC clustering and cache replication (improved HA) 🤙

![Logical Diagram](https://raw.githubusercontent.com/deadlysyn/terraform-keycloak-aws/main/assets/keycloak.png "Logical Diagram")

Psst: [Looking for IaC for Keycloak clients?](https://github.com/deadlysyn/keycloakinator)

## Prerequisites

- [aws v2 CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [aws-vault](https://github.com/99designs/aws-vault) installed and configured
- Terraform >= v0.12
- Docker (container build/deploy)
- UNIX-like OS (tested on Linux and MacOS)

## Workflow

The basic workflow relies on make to reduce typing toil.
If you are just getting started, refer to
[the bootstrapping guide](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/docs/bootstrapping.md).

```console
$ cd environments
$ make
Manage Keycloak Infrastructure

Requirements:
  aws-vault, terraform

Usage:
  make all             create environment with remote state
  make update          update environment
  make destroy         destroy environment

# Create new environment
$ ./mkenv -e <env_name> -r <aws_region>
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
memory reservations appropriately. For Datadog, you need to reserve and additional
256 CPU units and 512MB of memory.

## Strong Opinions Weakly Held

Similar to popular frameworks, bootstrap time is reduced by encapsulating technical opinions.
This saves you time, getting functional infrastructure online quickly and consistently.
However, you can easily adjust these as needed so this section attempts to call out key
design choices and how they can be modified.

### Don't Re-Invent the Wheel

The Keycloak module itself wraps only a few AWS Terraform primitives, preferring
trusted registry modules. Avoiding bespoke solutions where community-tested options
exist improves quality and reduces maintenance overhead.

We have contributed to many of these modules ourselves, and leverage them for
production infrastructures. We've taken the time to read the module source,
understand how they work, and reason about the choices they've made. You should do the
same (be mindful of your dependencies) to understand how they can be adjusted
if you find the defaults lacking.

Dependencies are conveniently linked in
[References](https://github.com/deadlysyn/terraform-keycloak-aws#references).

### An Exception to Every Rule

While there are a number of modules to create AWS network resources, networking
is an exception to the re-use rule above. The provided network module
is simplistic, but adequate and easy to tweak based on your requirements.

However, it is meant to serve two purposes: a starting point to get new environments
online quickly for experimentation, and interface documentation.
Taking it's outputs as an example, you can easily provide similar inputs
via configuration from existing infrastructure or a module of your choice.

### Encrypt Everything

Whether ALB listeners, ECR , or RDS... anything that can have encryption
enabled does by default. Aside from belief in the cypherpunk motto,
this is particularly due to the fact Keycloak is a security service.

The one exception today is intra-VPC traffic between the ALB and ECS containers.
Fixing this so service traffic is FULLY encrypted is on the TODO list (PRs welcome).

Aside from just "turning it on", thought is being given to cert management,
workflow, etc. For example, a sidecar proxy integrated with Let's Encrypt
would be more up-front complexity but not require updating container trust
stores, worrying about renewals, etc.

### Reduce Cognitive Load

Many of the opinions represented in code come from upstream defaults.
This reduces cognitive load for the operator. However, these are
only opinions. You should understand upstream module defaults, and
know that you can always override them if needed.

Aside from leveraging sensible defaults, we also hard-code
a few settings (e.g. DB port number) which are tunable but unlikely
to change in the typical case. Again, these can be overridden but
not forcing them to be thought about makes initial consumption
easier. Power users may want to go deeper.

Architectural choices such as "enough regions for HA"
or "database type" are currently baked in. Some of these can be easily
adjusted, others require larger refactors. As time permits, we
intend to make larger things like RDS cluster type easier to personalize,
but have erred on the side of simplicity.

The included
[standalone-ha.xml](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/build/keycloak/standalone-ha.xml)
and
[docker-entrypoint.sh](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/build/keycloak/docker-entrypoint.sh)
have been adjusted to work with ECS out of the box. These should suffice
in most cases, but may need adjusted based on your requirements.
You might also want to enable or disable different features, which
are controlled in
[profile.properties](https://github.com/deadlysyn/terraform-keycloak-aws/blob/main/build/keycloak/profile.properties).

## TODO

- Terratests
- Test with Terraform v0.14 once upstream modules are ready
- ALB -> ECS TLS
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

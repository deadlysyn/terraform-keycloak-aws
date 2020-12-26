# Upgrades

Always [browse the upgrade guide](https://www.keycloak.org/docs/latest/upgrading/index.html),
[read the release notes](https://www.keycloak.org/docs/latest/release_notes),
and test in a low-risk environment first.

Keycloak version upgrades are fairly painless, even across several major
versions. The configuration and database schema upgrades are automated.

## Prepare Database

Techncially you don't have to do anything. When you start a new container version,
Liquibase will auto-detect the older schema and take care of everything.

To be safe, you should backup the database before upgrading. You can simply
take a RDS snapshot or (also) use the scripts in the `db` directory to dump
and restore. These are very simple at the moment, but have been tested.
They can also be used to migrate data between clusters.

Shortly after starting a new container version, you should see this message in CloudWatch:

```console
[org.keycloak.connections.jpa.updater.liquibase.LiquibaseJpaUpdaterProvider] (ServerService Thread Pool -- 64) Updating database. Using changelog META-INF/jpa-changelog-master.xml
```

## Update Keycloak's Configuration

- [Download latest distribution](https://www.keycloak.org/downloads.html)
- Uncompress that somewhere (e.g. `build/keycloak/dist`)
- Change to the `keycloak-${version}/standalone/configuration` directory
- Backup the bundled `standalone-ha.xml` for reference
- Copy `build/keycloak/standalone-ha.xml` from this repo over the distribution config
- Change back to the `keycloak-${version}` directory
- Use CLI to migrate config: `./bin/jboss-cli.sh --file=bin/migrate-standalone-ha.cli`

## Update Container

- Change to `build/keycloak`
- Copy your newly updated `standalone-ha.xml` over the project's config
- Update the Dockerfile's `FROM` line with desired version
- Commit your changes

You can now deploy by running `make all ENV=<env_name>` in the build directory.
This will build the container, push to ECR and roll the service without downtime.

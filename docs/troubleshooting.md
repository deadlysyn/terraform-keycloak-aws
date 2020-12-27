# Contents

- [Logs](#logs)
  - [Access](#access)
  - [Examples](#examples)

## Logs

This project stores logs in CloudWatch. You can browse these via the AWS console,
or access them using a CLI from your machine.

To follow along you'll need:

- [aws-vault configured](https://github.com/99designs/aws-vault#quick-start)
- [cw installed](https://www.lucagrulla.com/cw)
- `AWS_PROFILE` and `AWS_REGION` exported

### Access

No special access is needed. Your standard admin role enables access to CloudWatch.
If desired, you can also configure a special role with read-only access.

### Examples

These examples walk you through the process of enumerating [CloudWatch
log groups and streams](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html)
because these are the primitives exposed by the `cw` CLI. Ensuring
you can enumerate groups and streams is a good way to verify
your access and CLI config are working.

Jump to the last example if you just want to quickly tail logs...
There is a log group per cluster, with naming convention of
`/aws/ecs/cluster/${namespace}-${name}-${environment}:${environment}/${name}`.

```console
# List log groups
$ aws-vault exec $AWS_PROFILE -- cw --region $AWS_REGION ls groups
/aws/ecs/cluster/n01113a46-keycloak-test
/aws/ecs/containerinsights/n01113a46-keycloak-test/performance
/aws/rds/cluster/n01113a46-keycloak-test-rds/error
RDSOSMetrics

# List log streams
$ aws-vault exec $AWS_PROFILE -- cw --region $AWS_REGION ls streams /aws/ecs/cluster/n01113a46-keycloak-test
test/keycloak/814585f5-52da-4544-a91c-1356606611af
test/keycloak/fe353380-f9dd-4ff4-a837-0c309f50f541

# Tail specific stream (isolate a specific container ID)
$ aws-vault exec $AWS_PROFILE -- cw --region $AWS_REGION tail -f /aws/ecs/cluster/n01113a46-keycloak-test:test/keycloak/814585f5-52da-4544-a91c-1356606611af
...

# Tail all streams in group (may be noisy, since it may include sidecars)
$ aws-vault exec $AWS_PROFILE -- cw --region $AWS_REGION tail -f /aws/ecs/cluster/n01113a46-keycloak-test
...

# Tail all logs with specified stream prefix (probably what you want)
$ aws-vault exec $AWS_PROFILE -- cw --region $AWS_REGION tail -f /aws/ecs/cluster/n01113a46-keycloak-test:test/keycloak
auth-staging-keycloak 2020-10-15 19:26:35,596 INFO  [org.keycloak.storage.ldap.LDAPStorageProviderFactory] (Timer-2) Sync of federation mapper 'group' finished. Status: UserFederationSyncResult [ 0 imported groups, 116 updated groups, 0 removed groups ]
auth-staging-keycloak 2020-10-15 19:26:35,597 INFO  [org.keycloak.storage.ldap.LDAPStorageProviderFactory] (Timer-2) Sync changed users from LDAP to local store: realm: test, federation provider: test.ldap.domain.tld, last sync time: Thu Oct 15 19:21:35 GMT 2020
auth-staging-keycloak 2020-10-15 19:26:38,296 INFO  [org.keycloak.storage.ldap.LDAPStorageProviderFactory] (Timer-2) Sync changed users finished: 0 imported users, 0 updated users
...
```

For more guidance, see `cw help tail`. I've had mixed results with the `-l`
option (format timestamps in local TZ). I've found it can ommit logs seen
when viewing with `-f` alone (UTC).

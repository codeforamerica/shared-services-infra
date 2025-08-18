---
title: Schema Reference
---
# App Spec Schema Reference

This shema is current as of June 26, 2025.

## `title`

`title` defines the human-readable name of the application and can contain
spaces and other special characters.

## `name`

`name` defines the machine-readable name of the application. It must be a
lowercase alphanumeric string with no spaces or special characters except for
dash (`-`).

The `name` is used in resource names, so make sure to use a name that isn't
likely to change.

## `name_short`

`name_short` defines a short name for the application. This is used in resources
that have a stricter character limit. Defaults to the value of `name` if not
provided.

## `program`

> [!TIP]
> Check with your team lead if you aren't sure which program to use.

`program` defines the program, within Code for America, that the application is
associated with. This is used to tag resources for billing and reporting
purposes. It should be a lowercase alphanumeric string with no spaces or special
characters except for dash (`-`).

## `repo`

`repo` defines the Git repository that contains the source code for the
application. It should include the owner and repository name in the format
`owner/repo`. This is reserved for future use.

## `enabled`

`enabled` defines whether the application is enabled. If set to `false`, the
application will not be deployed and will be destroyed if it exists. Defaults
to `true` if not provided.

## `internal`

`internal` defines whether the application is internal to the organization only.
If set to `true`, the load balancer will require authentication via Okta before
accessing the application. Defaults to `true` if not provided.

When set to `true`, a secret will be created in AWS Secrets Manager with the
name `<name>/<environment>/oidc`. This secret contains an `id` and `secret` key
that have been set to a default value. This secret _must be updated_ with the
appropriate values from Okta for the application to work correctly. After
updating the secret value, deploy the application again to update the load
balancer.

## `domain`

`domain` defines the domain for the application. This will be used as the domain
for any DNS entries created for the application. If not provided, the default
domain for the hosting environment will be used.

When `domain` is provided, a matching Route 53 Hosting Zone must already exist
for the domain in any account that it is deployed to.

## `subdomain`

`subdomain` defines the subdomain for the application, if any. This will be
used, along with `domain`, as the base for any DNS entries created for the
application. If not provided, a default subdomain may be used, depending on the
hosting environment.

## `database`

`database` defines the database configuration for the application, if any.

### `database.type`

`type` defines the type of database to use. Currently, only `mssql` is
supported.

### `database.version`

`version` defines the version of the specified database engine to use. If not
provided, the latest supported version will be used.

## `docs`

`docs` defines configuration for the application's documentation, if any.

### `docs.enabled`

`enabled` defines whether the documentation is enabled for the application. If
not provided, defaults to `true` when other attributes a present in `docs.*`,
otherwise defaults to `false`.

### `docs.private`

`private` defines whether the documentation is private to the organization,
requiring authentication to access. Defaults to `false` if not provided.

## `secrets`

`secrets` defines any secrets that the application requires. This is a map of
secret names to their configuration. The key for each secret should match the
format of the `name` attribute, unless it is provided explicitly.

The secrets will be created in AWS Secrets Manager with an empty value. Use
the `keys` attribute to define a set of keys that the application expects to be
present in the secret to create a JSON object with those keys set to empy
values.

Once the secrets have been created, you can update the values in AWS Secrets
Manager. You can find them under the path `<name>/<environment>/<secret.name>`.
The application may require a new deployment to ensure that it has access to the
updated secrets.

### `secrets.add_suffix`

`add_suffix` defines whether to add a random suffix to the secret name to
ensure uniqueness. This can be useful if you expect the secret to need to be
recreated to avoid name conflicts. However, this can make it more difficult to
find the secret by name alone, so use with caution. Defaults to `false` if not
provided.

### `secrets.name`

`name` defines the name of the secret. The name must be an alphanumeric
string with no spaces or special characters except for dash (`-`), underscore
(`_`) and forward slash (`/`). If not provided, the name will default to the key
used in the `secrets` map.

### `secrets.description`

`description` is an optional human-readable description of the secret. This is
used to provide context for the secret and is not used by the application.

### `secrets.type`

`type` defines the type of secret. Supported values are `string` and `json`. If
not provided, the default is `string`.

### `secrets.keys`

`keys` defines a list of expected keys for the secret, when the type is `json`.
Each key will be created with an empty value in the secret. This is useful
for applications that expect a specific key to exist and may fail to start if
the key is not present. If the type is `string`, this attribute is ignored.

## `services`

`services` defines the services that the application requires. This is a map
of service names to their configuration. The key for each service should match
the format of the `name` attribute, unless it is provided explicitly.

### `services.name`

`name` defines the name of the service. The name must be a lowercase
alphanumeric string with no spaces or special characters except for dash (`-`).
If not provided, the name will default to the key used in the `services` map.

### `services.image`

`image` defines the Docker image to use for the service. This should be a
fully qualified image name, including the registry, repository, and tag. If
not provided, an Elastic Container Registry (ECR) will be created for the
service, and you will need to push the image to the ECR before the application
can be deployed.

### `services.image_tag`

`image_tag` defines the tag to use for the Docker image. If not provided, an
SSM parameter will be created with the name
`/<name>/<environment>/<service.name>/version` and the value will be set to
`latest`. You can update this parameter to the correct tag and redeploy to
update the service. This allows you to deploy the application without needing to
update your app sec every time you want to change the image tag.

### `services.repository_arn`

`repository_arn` defines the ARN of the ECR repository where the image is
stored. This is only required if `image` is provided and the image is stored in
a private ECR repository.

### `services.desired_containers`

> [!TIP]
> To achieve high availability and avoid unexpected downtime, this value must
> be set to at least `2` in production environments.

`desired_containers` defines the number of containers to keep running for the
service at any time. If not provided, defaults to `2` in production
environments, and `1` otherwise. Set to `0` to disable the service.

### `services.health_check_path`

`health_check_path` defines the path to use for the service health check. This
is used to determine if the service is healthy and ready to receive traffic, and
is only used when the service is exposed via a load balancer. Defaults to
`/health` if not provided.

### `services.expose`

`expose` defines the port, if any, that should be exposed via a load balancer.
Only one port can be exposed per service.

### `services.public`

`public` defines whether the service should be publicly accessible via the
load balancer. If set to `true`, the service will be accessible via the
public Internet. If set to `false`, the service will only be accessible from
the private network. Defaults to `false` if not provided.

### `services.subdomain`

`subdomain` defines the subdomain for the service, if exposed via a load
balancer. This will be used, along with the `domain` defined in the app spec, to
create the DNS entry for the service. If not provided, defaults to the top-level
`name` defined in the app spec.

### `services.ports`

> [!NOTE]
> This is not a common scenario, and is typically only used when your services
> need to be able to communicate with each other over specific ports.

`ports` defines additional ports that the service listens on. This is a list of
port numbers that will be opened to the private network. The `expose` port _does
not_ need to be included in this list, as it is automatically opened to the
load balancer. If not provided, no additional ports will be opened.

### `services.volumes`

`volumes` defines the volumes that the service requires. This is a map of volume
names to their configuration. The key for each volume should match the format of
the `name` attribute, unless it is provided explicitly.

#### `services.volumes.name`

`name` defines the name of the volume. The name must be a lowercase alphanumeric
string with no spaces or special characters except for dash (`-`). If not
provided, the name will default to the key used in the `volumes` map.

#### `services.volumes.type`

`type` defines the type of volume to use. Currently, only `persistent` is
supported, which will create an EFS volume mounted to the service containers.
Defaults to `persistent` if not provided.

#### `services.volumes.mount`

`mount` defines the mount point for the volume inside the service container.

### `services.secrets`

`secrets` defines secrets to be injected into the container as environment
variables. The referenced secrets and they default keys should be defined in
the top-level `secrets` section of the app spec. The key for each secret
should match the format of the `env` attribute, unless it is provided
explicitly.

#### `services.secrets.env`

`env` defines the environment variable to inject the secret into. The name be an
uppercase alphanumeric string with no spaces or special characters except for
underscore (`_`). If not provided, the name will default to the key used in the
`secrets` map.

#### `services.secrets.name`

> [!TIP]
> You always want to use the key from the top-level `secrets` section to
> reference it, even if you explicitly provided a different `name` for the
> secret.

`name` defines the name of the secret to inject. The name must match the _key_
of the secret in the top-level `secrets` section of the app spec.

#### `services.secrets.key`

`key` defines the key in the secret to inject into the environment variable.
This is only necessary if the secret is of type `json`.

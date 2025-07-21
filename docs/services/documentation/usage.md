---
title: Usage
weight: -5
---
# Documentation Usage

Like our [shared hosting service][shared-hosting], this service uses our
[application specification][appspec] to define the documentation and its
required components. The specification does not need to be complex or include
any services, but it must have a [`docs`][appspec.docs] section defined.

## Example specification

```yaml title="my-app.yaml"
--8<-- "docs/assets/sample-docs.yaml"
```

## Adding your documentation

> [!CAUTION]
> By default, documentation is public and can be accessed by anyone with the
> URL. At Code for America, we like to work in the public and making your
> documentation available to all is a reflection of that. As such, documentation
> should not include any sensitive information, using only fake data or example
> content.
>
> If, for some reason, you have documentation that needs to be made private, you
> can set the `private` field in your app spec to `true`. This will require
> requests to be authenticated using Okta before allowing access to the
> documentation.

1. Clone the [`codeforamerica/shared-hosting-infra`][repo] repository
1. Create a new branch for your changes
1. Add your app sec file in the `tofu/config/development/docs/apps`
   directory, naming it according to the application (e.g. `my-app.yaml`)
1. Open a pull request to the `main` branch of the repository
1. Ensure that status checks pass for the pull request

### Review and setup

The DevOps team will review the pull request and, once approved, will create
resources in your repository that will allow you to deploy your documentation.

- An environment, if one does not already exist, that will be used to build and
  push updated documentation
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment secrets that are
  required to build and push updated documentation
- A deployment workflow that will build (if using MkDocs) and push the generated
  documentation to S3

You may need to update the deployment workflow to include any additional build
steps, particularly if you _aren't_ using MkDocs, or if you need to install
additional plugins.

## Deploying your documentation

Once these have been created, you can use the new [documentation deployment
workflow][deployment] to deploy your documentation.

[appspec]: ../appspec/index.md
[appspec.docs]: ../appspec/reference.md#docs
[deployment]: deployment-workflow.md
[repo]: https://github.com/codeforamerica/shared-hosting-infra
[shared-hosting]: ../hosting/index.md

---
title: Usage
weight: -5
---
# Static App Hosting Usage

Adding a static app to the platform requires two things: an application
specification that registers the app with the infrastructure, and a deployment
workflow in your application's repository.

## Adding your application

1. Clone the [`codeforamerica/shared-services-infra`][repo] repository
1. Create a new branch for your changes
1. Add an app spec file in the `tofu/configs/static/apps/` directory, naming
   it after the application (e.g. `my-app.yaml`)
1. Open a pull request to the `main` branch of the repository
1. Ensure that status checks pass for the pull request

### App spec format

Your app spec must include `type: static`. A minimal spec looks like this:

```yaml title="tofu/configs/static/apps/my-app.yaml"
--8<-- "docs/assets/sample-static-app.yaml"
```

See the [appspec schema reference][appspec] for all available fields. For
static apps, most service-specific fields (`database`, `services`, `secrets`)
do not apply.

### Review and setup

The DevOps team will review the pull request and, once approved, will apply
the infrastructure changes and configure your application's repository with
the values it needs to deploy.

> [!NOTE]
> The GitHub environment variables and secrets listed below are managed by the
> DevOps team. You do not need to create them.

The following will be added to your repository's `development` environment:

- `AWS_STATIC_ROLE_ARN` — secret; the IAM role your deploy workflow assumes
  to write to S3. Scoped to your app's bucket only.
- `STATIC_BUCKET` — variable; the name of your app's dedicated S3 bucket
  (e.g. `static-apps-development-my-app`)
- `STATIC_PREFIX` — variable; your app's URL path segment
  (e.g. `my-app`). Used for CloudFront cache invalidation — not an S3
  key prefix. Files are synced to the bucket root.
- `CLOUDFRONT_DISTRIBUTION_ID` — variable; the shared CloudFront
  distribution ID, used to invalidate the cache for your app's path on deploy

## Deployment

Once DevOps has configured your repository, add the deployment workflow
described in [deployment workflow][deployment]. On the next push to `main`,
your files will be synced to S3 and your app will be available at:

```
https://apps.dev.services.cfa.codes/<your-app-name>/
```

An unauthenticated request will redirect to Okta. An authenticated request
will serve your files directly.

## Updating your app

Subsequent deployments work the same way: push to `main` and the workflow
runs. The S3 sync uses `--delete`, so files removed from your repository will
be removed from S3 on the next deploy.

[appspec]: ../appspec/reference.md
[deployment]: deployment-workflow.md
[repo]: https://github.com/codeforamerica/shared-services-infra

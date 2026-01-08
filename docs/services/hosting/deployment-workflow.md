---
title: Deployment Workflow
---
# Shared Hosting Deployment Workflow

To deploy an application to the shared hosting environment, a deployment
workflow is required. This will be added to your repository by the DevOps team,
via pull request, after your application has been [reviewed and
approved][review].

The default deployment workflow is designed to build and push the Docker image
for your application, then issue a deployment request to the shared hosting
service. You may need to update the workflow to include any additional build
steps, such as running tests or building static assets.

## DIY

If you'd like to get a head start on your deployment workflow, you can use the
default workflow template provided below. This template is a YAML file defining
a workflow for GitHub Actions.

Follow the steps below to add the workflow to your repository:

1. Copy the template below
1. Paste the contents into a new file in your repository at
   `.github/workflows/deploy.yaml`
1. Update the `APPLICATION` environment variable to match your application's
   name; this should match the name of your app spec file, without the
   `.yaml` extension (e.g. `my-app.yaml` would be `my-app`)
1. Add your additional build steps, as needed, before the
   `Build and push Docker image` step

## Secrets and variables

> [!TIP]
> The DevOps team will set the appropriate secrets and variables documented
> below. You can add additional secrets and variables that shoudl be synced to
> GitHub.

We use [Doppler] to manage secrets across projects and environments. If you
don't already have a Doppler project and environment, one will be created for
you. Secrets from the `ci` environment will be synced to GitHub Environments
for use in GitHub Actions.

In addition to the secrets added directly to the `ci` environment, an
[inherited config][config-inheritance] will be added, which will add the values
needed to deploy the application.

### Direct secrets

The following secrets are used push container images, and update the version
SSM parameter. They are unique to your project and environment and provide
minmal access.

| Name                      | Description                                                           |
|---------------------------|-----------------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`       | AWS access key ID with access to the shared services environment.     |
| `AWS_SECRET_ACCESS_KEY`   | AWS secret access key with access to the shared services environment. |


### Inherited secrets

These secrets are inherited from the shared services project and managed by the
DevOps team. They allow your repository to trigger the application deployment
workflow on the sahred services repository.

| Name                  | Description                                          |
|-----------------------|------------------------------------------------------|
| `DEPLOYMENT_APP_ID`   | ID of the GitHub App used for authorization.         |
| `DEPLOYMENT_APP_KEY`  | Private key to authenticate with the GitHub App.     |

### Inherited variables

Like the secrets above, these variables are inherited from teh shared services
project. They represent insecure values necessary to identify the target of
deployments.

| Name          | Description                                                      |
|---------------|------------------------------------------------------------------|
| `AWS_REGION`  | The AWS region where the shared services environment is located. |

## How it works

The deployment workflow is designed to automate the process of building and
deploying new versions of your application. It does this by:

1. Building a new Docker image for your application
1. Tagging the image as a new version[^1]
1. Pushing the image to Elastic Container Registry (ECR)
1. Setting the new version in AWS Systems Manager (SSM) Parameter Store
1. Triggering a deployment in the shared services infrastructure repository for
   the specific application and environment, which will handle deploying the
   new version to Elastic Container Service (ECS)
1. Waiting for the deployment to complete
2. Reporting success[^2]

The following sequence diagram illustrates the flow of the deployment workflow
and how the various components interact during the process:

```mermaid
sequenceDiagram
  box GitHub
    participant AR as App Repo
    participant IR as Infra Repo
  end
  box AWS
    participant ECR
    participant SSM as Parameter Store
    participant ECS
  end

  activate AR
  AR->>ECR: Push Docker image
  AR->>SSM: Set version parameter
  AR->>+IR: Trigger infra deployment
  AR-->>AR: Poll workflow status
  IR->>SSM: Read version parameter
  IR->>+ECS: Deploy new version
  AR-->>IR: Workflow success
  deactivate IR
  AR->>AR: Report success
  deactivate AR
  ECS->>ECR: Pull Docker image
  ECS->>ECS: Start new containers
  ECS->>-ECS: Terminate old containers
```

## Template

```yaml title=".github/workflows/deploy.yaml"
--8<-- "docs/assets/app-deployment-workflow.yaml"
```

[config-inheritance]: https://docs.doppler.com/docs/config-inheritance
[doppler]: https://www.doppler.com/
[review]: usage.md#review-and-setup

[^1]: By default, the new version is based on the latest SHA. You may want to
      update this match the versioning scheme used by your application.
[^2]: Success/failure is reported as the job status in GitHub Actions.
      You can also add additional steps to notify your team via Slack,
      PagerDuty, or other means.

---
title: Usage
weight: 10
---
# Shared Hosting Usage

You will need to create an [application specification][appspec] that defines the
application and its required components. This specification is a YAML file
that describes the application, its containers, volumes, and other settings.

## Adding your application

1. Clone the [`codeforamerica/shared-hosting-infra`][repo] repository
1. Create a new branch for your changes
1. Add your app sec file in the `tofu/config/development/infra/apps`
   directory, naming it according to the application (e.g. `my-app.yaml`)
1. Open a pull request to the `main` branch of the repository
1. Ensure that status checks pass for the pull request

### Review and setup

The DevOps team will review the pull request and, once approved, will create
resources in your repository that will allow you to deploy your application.

- A repository secret named `DEPLOYMENT_PAT` that will be used to start the
  shared services deployment workflow
- A `development` environment, if one does not already exist, that will be used
  to build and push updated docker images for the application
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment secrets that are
  required to build and push updated docker images
- A deployment workflow that will build and push the docker images, then issue
  a deployment request to the shared hosting service

You may need to update the deployment workflow to include any additional build
steps. By default, it will build the Docker image using the `Dockerfile` in the
application's root directory.

## Deployment

Once these have been created, the DevOps team will create the initial
deployment. This will create the container registry, but you will need to push
your Docker images to the registry, using the provided workflow, before the
application can be deployed.

This will deploy your application to the _development_ environment of the shared
hosting service. Review the deployed application to ensure it works as expected.

You can continue to make changes to your application and push updates using the
[deployment workflow][deployment].

## Promoting your application

The development environment is intended for testing and development purposes. As
such, it's susceptible to changes and may not be stable.

> [!CAUTION]
> While this service is in its experiemntal phase, we do not yet have a
> production environment for shared hosting. We recommend using this service
> for development and testing purposes only.

[appspec]: ../appspec/index.md
[deployment]: deployment-workflow.md
[repo]: https://github.com/codeforamerica/shared-hosting-infra

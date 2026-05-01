---
title: Overview
weight: -10
---
# Shared Hosting

> [!CAUTION]
> This service is experimental and not intended for production use. See below
> for the current feature set and limitations.

While many of our public services require a high level of isolation, this isn't
necessary for small internal tools, proof-of-concepts, demos, or other smaller
projects. For these, we provide a shared hosting environment that abstracts much
of the underlying infrastructure and deployment details, allowing teams to
quickly deploy prototypes for feedback, or building new services without the
burden of fully maintaining their hosted tooling.

## Scope of this section

This section covers **container-based deployments**: Docker containers running
on ECS behind a load balancer. This is the right path for applications with
persistent data, server-side logic, or credentialed API calls. The usage
guide here assumes an engineering audience working directly with the
infrastructure repository.

SharedServices also supports **static deployments** — files served from S3
via CloudFront — documented separately under [Static App Hosting][static].

For engineering-adjacent teams building internal tools, the
[sharedservices-app-template][template] provides a builder-friendly entry
point for both deployment types. It handles the scaffolding and configuration
that this guide asks you to do manually.

## Limitations

This is still an experimental service with limited support. New features are
added as needed and contributions are welcome. The current feature set supports
the following:

- **Containers**: Deployments are based on Docker containers
- **Persistent volumes**: Containers can be configured to use a persistent
  volume (EFS) for data storage
- **Microsoft SQL Server**: Applications can be configured to use a
  Microsoft SQL Server database
- **Internal only**: Services can be configured as internal only, requiring
  authentication to access
- **Multiple _independent_ services**: Multiple services can be deployed for an
  application, but they are not connected to each other and have their own
  container registry

[appspec]: ../architecture/appspec.md
[repo]: https://github.com/codeforamerica/shared-services-infra
[static]: ../static/index.md
[template]: https://github.com/codeforamerica/sharedservices-app-template

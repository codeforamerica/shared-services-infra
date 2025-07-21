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

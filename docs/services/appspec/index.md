---
title: Overview
weight: -10
---
# App Spec

> [!CAUTION]
> App specs are still experimental, and the schema may change as we continue to
> refine the service. Please check back for updates.

An application specification (app spec) is a YAML file that defines an
application and its required components. It describes the application, its
containers, volumes, and other settings. The app spec is used to deploy the
application using Code for America's internal hosting services.

## Schema

See the [app spec schema reference][reference] for a complete list of
supported options and their details.

## Example

```yaml title="app.yaml"
--8<-- "docs/assets/sample-app.yaml"
```

[reference]: reference.md

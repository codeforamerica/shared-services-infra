---
title: Overview
weight: -10
---
# Static App Hosting

> [!CAUTION]
> This service is experimental and not intended for production use. See below
> for the current feature set and limitations.

Not every internal tool needs a server. For applications that display data,
provide reference information, or run entirely in the browser, a static
deployment is simpler, cheaper, and faster to ship than a container.

Static app hosting serves files directly from S3 via CloudFront, behind the
same Lambda@Edge Okta SSO layer that protects container apps. From the user's
perspective, a static app looks identical to any other internal tool: it
requires authentication and lives at a subdomain of `apps.services.cfa.codes`.
The difference is entirely in what's behind the URL.

## When to use static hosting

Static hosting is right for:

- **Dashboards and data displays** — HTML that reads from a public or
  pre-built data source
- **Reference pages** — documentation, process guides, resource indexes
- **Calculators and form tools** — browser-side logic with no data that needs
  to persist
- **Prototypes** — fast, low-overhead deploys for early feedback

It is not right for:

- **Apps where users submit data that needs to be stored** — that state has
  nowhere to go without a server
- **Apps that call credentialed APIs at runtime** — secrets cannot be exposed
  to a static site without becoming public
- **Apps with background jobs or scheduled processing** — those require a
  container

If you're unsure, the [sharedservices-app-template][template] includes a
decision guide that walks through the tradeoffs.

## How it fits into the platform

SharedServices supports two deployment types: `container` and `static`. Both
are first-class paths on the platform, backed by the same underlying
infrastructure (AWS, Okta SSO, Doppler for secrets). The difference is the
shape of what gets deployed:

- **`container`** — a Docker container running on ECS, accessed through a load
  balancer. The full operational path for this type is documented in
  [shared hosting][hosting].
- **`static`** — files synced to S3, served through CloudFront. That's this
  section.

Both paths are accessible to engineering teams directly through this
repository. For engineering-adjacent teams building internal tools,
[sharedservices-app-template][template] provides a builder-friendly entry
point for both types.

## Current feature set

- **S3 + CloudFront delivery** — files are served with low latency and
  configurable cache behavior
- **Okta SSO protection** — all prefixes are OIDC-protected at the edge; no
  unauthenticated access
- **Per-app deploy isolation** — each app gets its own IAM role scoped to its
  S3 prefix; a compromised deploy credential cannot affect other apps
- **Optional CloudFront cache invalidation** — on deploy, the cache for the
  app's prefix can be invalidated automatically

## Limitations

This is still an experimental service with limited support. Notable
constraints at this time:

- **No server-side logic** — there is no runtime; everything runs in the
  browser
- **No secrets at runtime** — credentials cannot be made available to a
  static site without exposing them to the public
- **Adding a new app requires a DevOps PR** — per-app specs in
  `tofu/configs/static/apps/` are not yet self-service
- **Single environment** — only a development environment is available while
  the service is experimental

[hosting]: ../hosting/index.md
[template]: https://github.com/codeforamerica/sharedservices-app-template

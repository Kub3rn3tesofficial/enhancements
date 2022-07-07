<!--
**Note:** When your KEP is complete, all of these comment blocks should be removed.

To get started with this template:

- [x] **Pick a hosting SIG.**
  Make sure that the problem space is something the SIG is interested in taking
  up. KEPs should not be checked in without a sponsoring SIG.
- [ ] **Create an issue in kubernetes/enhancements**
  When filing an enhancement tracking issue, please make sure to complete all
  fields in that template. One of the fields asks for a link to the KEP. You
  can leave that blank until this KEP is filed, and then go back to the
  enhancement and add the link.
- [x] **Make a copy of this template directory.**
  Copy this template into the owning SIG's directory and name it
  `NNNN-short-descriptive-title`, where `NNNN` is the issue number (with no
  leading-zero padding) assigned to your enhancement above.
- [x] **Fill out as much of the kep.yaml file as you can.**
  At minimum, you should fill in the "Title", "Authors", "Owning-sig",
  "Status", and date-related fields.
- [x] **Fill out this file as best you can.**
  At minimum, you should fill in the "Summary" and "Motivation" sections.
  These should be easy if you've preflighted the idea of the KEP with the
  appropriate SIG(s).
- [ ] **Create a PR for this KEP.**
  Assign it to people in the SIG who are sponsoring this process.
- [ ] **Merge early and iterate.**
  Avoid getting hung up on specific details and instead aim to get the goals of
  the KEP clarified and merged quickly. The best way to do this is to just
  start with the high-level sections and fill out details incrementally in
  subsequent PRs.

Just because a KEP is merged does not mean it is complete or approved. Any KEP
marked as `provisional` is a working document and subject to change. You can
denote sections that are under active debate as follows:

```
<<[UNRESOLVED optional short context or usernames ]>>
Stuff that is being argued.
<<[/UNRESOLVED]>>
```

When editing KEPS, aim for tightly-scoped, single-topic PRs to keep discussions
focused. If you disagree with what is already in a document, open a new PR
with suggested changes.

One KEP corresponds to one "feature" or "enhancement" for its whole lifecycle.
You do not need a new KEP to move from beta to GA, for example. If
new details emerge that belong in the KEP, edit the KEP. Once a feature has become
"implemented", major changes should get new KEPs.

The canonical place for the latest set of instructions (and the likely source
of this file) is [here](/keps/NNNN-kep-template/README.md).

**Note:** Any PRs to move a KEP to `implementable`, or significant changes once
it is marked `implementable`, must be approved by each of the KEP approvers.
If none of those approvers are still appropriate, then changes to that list
should be approved by the remaining approvers and/or the owning SIG (or
SIG Architecture for cross-cutting KEPs).
-->
# KEP-2906: Kustomize Function Catalog

<!--
A table of contents is helpful for quickly jumping to sections of a KEP and for
highlighting any additional information provided beyond the standard KEP
template.

Ensure the TOC is wrapped with
  <code>&lt;!-- toc --&rt;&lt;!-- /toc --&rt;</code>
tags, and then generate with `hack/update-toc.sh`.
-->

<!-- toc -->
- [Release Signoff Checklist](#release-signoff-checklist)
- [Summary](#summary)
  - [Key terminology](#key-terminology)
- [Motivation](#motivation)
  - [Goals](#goals)
  - [Non-Goals](#non-goals)
- [Proposal](#proposal)
  - [User Stories (Optional)](#user-stories-optional)
    - [Story 1](#story-1)
    - [Story 2](#story-2)
    - [Story 3](#story-3)
    - [Story 4](#story-4)
    - [Story 5](#story-5)
    - [Story 6](#story-6)
    - [Story 7](#story-7)
  - [Notes/Constraints/Caveats (Optional)](#notesconstraintscaveats-optional)
  - [Risks and Mitigations](#risks-and-mitigations)
- [Design Details](#design-details)
  - [Function Metadata Schema](#function-metadata-schema)
  - [Determining the Function to Execute](#determining-the-function-to-execute)
  - [Use of OCI Artifacts](#use-of-oci-artifacts)
  - [OCI Artifacts](#oci-artifacts)
  - [Test Plan](#test-plan)
  - [Graduation Criteria](#graduation-criteria)
    - [Alpha](#alpha)
    - [Beta](#beta)
    - [GA](#ga)
    - [Deprecation](#deprecation)
  - [Upgrade / Downgrade Strategy](#upgrade--downgrade-strategy)
  - [Version Skew Strategy](#version-skew-strategy)
- [Production Readiness Review Questionnaire](#production-readiness-review-questionnaire)
  - [Feature Enablement and Rollback](#feature-enablement-and-rollback)
  - [Rollout, Upgrade and Rollback Planning](#rollout-upgrade-and-rollback-planning)
  - [Monitoring Requirements](#monitoring-requirements)
  - [Dependencies](#dependencies)
  - [Scalability](#scalability)
  - [Troubleshooting](#troubleshooting)
- [Implementation History](#implementation-history)
- [Drawbacks](#drawbacks)
- [Alternatives](#alternatives)
- [Infrastructure Needed (Optional)](#infrastructure-needed-optional)
<!-- /toc -->

## Release Signoff Checklist

<!--
**ACTION REQUIRED:** In order to merge code into a release, there must be an
issue in [kubernetes/enhancements] referencing this KEP and targeting a release
milestone **before the [Enhancement Freeze](https://git.k8s.io/sig-release/releases)
of the targeted release**.

For enhancements that make changes to code or processes/procedures in core
Kubernetes—i.e., [kubernetes/kubernetes], we require the following Release
Signoff checklist to be completed.

Check these off as they are completed for the Release Team to track. These
checklist items _must_ be updated for the enhancement to be released.
-->

Items marked with (R) are required *prior to targeting to a milestone / release*.

- [ ] (R) Enhancement issue in release milestone, which links to KEP dir in [kubernetes/enhancements] (not the initial KEP PR)
- [ ] (R) KEP approvers have approved the KEP status as `implementable`
- [ ] (R) Design details are appropriately documented
- [ ] (R) Test plan is in place, giving consideration to SIG Architecture and SIG Testing input (including test refactors)
  - [ ] e2e Tests for all Beta API Operations (endpoints)
  - [ ] (R) Ensure GA e2e tests for meet requirements for [Conformance Tests](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/conformance-tests.md) 
  - [ ] (R) Minimum Two Week Window for GA e2e tests to prove flake free
- [ ] (R) Graduation criteria is in place
  - [ ] (R) [all GA Endpoints](https://github.com/kubernetes/community/pull/1806) must be hit by [Conformance Tests](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/conformance-tests.md) 
- [ ] (R) Production readiness review completed
- [ ] (R) Production readiness review approved
- [ ] "Implementation History" section is up-to-date for milestone
- [ ] User-facing documentation has been created in [kubernetes/website], for publication to [kubernetes.io]
- [ ] Supporting documentation—e.g., additional design documents, links to mailing list discussions/SIG meetings, relevant PRs/issues, release notes

<!--
**Note:** This checklist is iterative and should be reviewed and updated every time this enhancement is being considered for a milestone.
-->

[kubernetes.io]: https://kubernetes.io/
[kubernetes/enhancements]: https://git.k8s.io/enhancements
[kubernetes/kubernetes]: https://git.k8s.io/kubernetes
[kubernetes/website]: https://git.k8s.io/website

## Summary

Introduce a new API (`kind`) that will provide a mechanism to improve distribution and discovery of Kustomize functions, for use with `Kustomization`, `Components`, and `Composition` resources.

This new API will provide a standardized way to define a collection of one or more Kustomize functions, as well as supporting KRM-style configuration resources, that can be consumed by Kustomize in order to automate the use of functions and eliminate manual out-of-band discovery and installation steps, regardless of the packaging format. All Kustomize configuration objects (i.e. Kustomization, Component and Composition) will support function source configuration via this new kind. Ideally, we would like the new API to become a standard that other KRM-style transformer orchestrators such as KPT can adopt as well.

### Key terminology

*KRM*: [Kubernetes Resource Model](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md)

 *Function*: A program conforming to the spec described in [this document](https://github.com/kubernetes-sigs/kustomize/blob/master/cmd/config/docs/api-conventions/functions-spec.md#krm-functions-specification).

 *Function config*: The KRM-style YAML document that declares the desired state the function implements well as the function runtime to execute and the specification to follow in doing so. Analogous to a custom resource object.
 

## Motivation

The use of Kustomize functions today is cumbersome, both in terms of discovery and the use of functions within a Kustomization. The introduction of the `Composition` API will improve function workflows, but challenges remain surrounding function distribution and discovery. This KEP is motivated by this need to improve the distribution and discovery of functions, for use in `Composition` or other Kustomize resources. 

In order to use Kustomize functions today, an end user must explicitly provide a reference to the function implementation. For example, consider the use of a function with a Kustomization. First, the user would define a resource configuration as follows:

```yaml
apiVersion: team.example.com/v1alpha1
kind: HTTPLoadBalancer
metadata:
  name: lb
  annotations:
    config.kubernetes.io/function: |
      container:
        image: docker.example.com/kustomize-modules/lb:v0.1.1
spec:
  selector:
    matchLabels:
      app: nginx-example
  expose:
    serviceName: nginx
    port: 80
```

This is then referenced from a Kustomization in the following way:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

transformers:
- lb.yaml
```

This explicit configuration requires the user to include two separate pieces of configuration to use the function: 
* they must provide the API Version and Kind
* they must provide an explicit reference to the Docker container that will be used 

When using a container based function with the `Composition` API, the user must still specify this information:

```yaml
# app/composition.yaml
kind: Composition

modules:
# generate resources for a Java application
- apiVersion: example.com/v1
  kind: JavaApplication
  runtime: {container: {image: example/module_providers/java:v1.0.0}}
  spec:
    application: team/my-app
    version: v1.0
```

Once the explicit container reference is provided, Kustomize is able to download and run this image as part of the Kustomize build step, by invoking the user installed Docker client and leveraging local images or OCI registries. In addition to container based functions, ad-hoc functions can also currently be written using the [Starlark programming language](https://github.com/bazelbuild/starlark) and other non-container based mechanisms. Unlike container based functions, these functions do not currently have an associated registry concept and they must be stored locally. Discovery and installation of these runtimes are both currently left to the users. 

In addition to these user defined functions, this KEP is also partially motivated by a need to change how Kustomize provides officially supported functionality. Currently, to support a given piece of functionality officially a built-in function must be created (and typically also added to the Kustomization API). Some of these features would be better implemented as extensions for security reasons or to limit the dependency graph of Kustomize and the integration with kubectl. No mechanism currently exists, however, to support official distribution of these capabilities, so they are instead built into Kustomize. This would also enable the Kustomize maintainers to make breaking changes to address legacy technical debt, without needing to update all functions as part of that action. This would also enable users to mix and match the version of the Kustomize binary with function versions, enabling a less disruptive migration approach. 

As an example, the Helm functionality built into Kustomize currently relies on the user to install Helm as a separate step. This in turn requires the use of special flags on invocation to use, for security reasons. If the Helm integration was instead built and distributed as a container based function, the implementation could instead use the Helm Go packages and be built independently of Kustomize and distributed to users of Kustomize through an official channel. 

### Goals

Develop an API (`kind`) for Kustomize that is focused on function discovery, as well as guidelines and recommendations for distribution of functions and associated resources, such as schema definitions.

A successful implementation of this API should have the following characteristics:

1. Function based workflows are driven by seamless invocation of sets of functions without individual out-of-band discovery or installation steps for specific runtimes.
1. The new API is integrated with the existing Kustomize tool (i.e. `kustomize build`) through references provided in Kustomization, Component, and Composition resources.
1. Eligible Kustomize functionality could be extracted and distributed as official extensions. This won't be completed as part of this KEP but the required changes to support this will be implemented. 

### Non-Goals

1. Support anything other than KRM-style functions that follow the [functions spec](https://github.com/kubernetes-sigs/kustomize/blob/master/cmd/config/docs/api-conventions/functions-spec.md)
1. Directly implement capabilities to publish function or other resources to OCI registries 

## Proposal

In order to standardize function discovery, introduce a `Catalog` API `kind` recognized by `kustomize build`. One or more `Catalog` resources can be referenced from any Kustomize kind as either a local file or remote reference available as from an HTTP(s) endpoint or as an [OCI artifact](https://github.com/opencontainers/artifacts).

A `Catalog` will contain a collection of one or more functions that can be used with a Kustomize resource. 

A minimal example is shown below:

```yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "example-co-functions"
spec: 
  krmFunctions: 
  - group: example.com
    names:
      kind: JavaApplication
    description: "A Kustomize function that represents a Java based app"
    versions:
    - name: v1
    runtime: 
      container: 
        image: example/module_providers/java:v1.0.0
```

This will enable a users to use a function with runtime information omitted, such as:

```yaml
# app/kustomization.yaml
kind: Kustomization
catalogs:
  - catalog.yaml
transformers:
- javaapp.yaml
```

```yaml
# app/javaapp.yaml
apiVersion: example.com/v1
kind: JavaApplication
spec:
  application: team/my-app
  version: v1.0
```

When this Kustomization is processed by `kustomize build`, the referenced catalog (or catalogs) will be used to locate a function implementation that supports the apiVersion `example.com/v1` and kind `JavaApplication`. If found in one of the referenced catalogs, kustomize can determine the runtime configuration without the need for the user to specify it in the kustomization resources directly. The catalogs will be searched in order specified. If more than one catalog defines the target apiVersion and kind, the first will be selected. A catalog can be referenced by either a local file reference or a remote HTTPS, Git, or OCI reference.

In addition to the new catalog kind, `kustomize build` will accept a repeatable flag `--trusted-catalog=""`. The values passed to this flag should match the values declared within the catalog. When present, this flag instructs `kustomize build` to automatically fetch and execute functions that are defined by the catalog and referenced within the Kustomization, Component or Composition, if needed. When a resource is processed by `kustomize build` and a catalog is referenced but not specified using the `--trusted-catalog=""` flag, an error will occur. 

To support the user experience of using catalogs, we will also add a `kustomize view catalog` command that will display catalog configuration, including publisher information retrieved from the catalog itself, in order to support the trust determination process.

Kustomize can at a later date provide a built in Catalog for supporting official extensions, published to a well publicized endpoint. This catalog will _NOT_ require the user to explicitly trust it. Users can provide the `apiVersion` and `kind` of the official extensions in kustomize resource and these will be resolved by the official catalog.

In addition to container based functions, the `Catalog` will support discovery of Starlark and Exec based functions, via an HTTP(s), Git, or OCI reference as illustrated below: 

```yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "example-co-functions"
spec: 
  krmFunctions: 
  - group: example.com
    names:
      kind: GroovyApplication
    description: "A Kustomize function that can handle groovy apps"
    versions:
    - name: v1
    runtime:  
      starlark: https://example.co/module_providers/starlark-func:v1.0.0
```

This concept can be extended later to support additional function packaging, but is out of scope for the current proposal.

When HTTP(s) references are used, the HTTP(s) endpoint must support anonymous access for reading resources. Resources will be expected to be stored as a single file, such as `catalog.yaml`. Git or OCI references can be authenticated or anonymous, and will use appropriate configuration from the users file-system. 

 
### User Stories (Optional)

#### Story 1

As a platform developer at enterprise company Example Co, I want to publish a catalog of Kustomize functions that represent custom capabilities important for our internal Kubernetes platform. I have built and published several Kustomize functions, packaged as Docker images, to our internal Docker registry: `docker.example.co`.

To do this, I build a new `Catalog` API resource: 

```yaml
# catalog.yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "example-co-functions"
spec: 
  krmFunctions: 
  - group: example.com
    names:
      kind: JavaApplication
    description: "A Kustomize function that can handle Java apps"
    versions:
    - name: v1
    runtime: 
      container: 
        image: docker.example.co/functions/java:v1.0.0
  - group: example.com
    names:
      kind: Logger
    description: "A Kustomize function that adds our bespoke logging"
    versions:
    - name: v1
    runtime: 
      container: 
        image: docker.example.co/functions/logger:v1.0.0
  - group: example.com
    names:
      kind: SecretSidecar
    description: "A Kustomize function that adds our bespoke secret sidecar"
    versions:
    - name: v1
    runtime: 
      container: 
        image: docker.example.co/functions/secrets:v1.0.0
```

I then publish this catalog to https://example.co/kustomize/catalog.yaml, for use by Example Co Kustomize users.

#### Story 2

As an application developer at Example Co, I want to use the published Example Co Catalog in the `Kustomization` for my application, after locating the published location of the catalog. I copy the Catalog to the file system, parallel to my `Kustomization`, so that I can version control it along with my other resources.

While building my `Kustomization`, I don't want to care about the runtime configuration and I want Kustomize to figure things out for me, based on the catalog.


```yaml
# app/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
catalogs:
  - catalog.yaml
transformers:
- java.yaml
- secrets.yaml
```

```yaml
# app/java.yaml
apiVersion: example.com/v1
kind: JavaApplication
spec:
  application: team/my-app
  version: v1.0
```

```yaml
# app/secrets.yaml
apiVersion: example.com/v1
kind: SecretSidecar
spec:
  key: my.secret.value
  path: /etc/secrets
```

I then run `kustomize build app/ -catalog=https://example.co/kustomize/catalog.yaml`. 

When this command is run, Kustomize detects the use of `example.com/v1/JavaApplication` and `example.com/v1/SecretSidecar`. As these are not built in transformers and there was no explicit runtime configuration specified, Kustomize will check for any referenced catalogs. It will see that I have specified `https://example.co/kustomize/catalog.yaml` and allowed it as a trusted catalog. It will then fetch the catalog and attempt to resolve these two transformers. It will match the specified apiVersion and Kinds with entries in the catalog and utilize the referenced docker images for the runtime configuration.

#### Story 3

As an application developer at Example Co, I want to use the published Example Co Catalog in the `Composition` for my application, but I want to pin to a specific version of the `SecretSidecar` module . While building my `Composition`, I don't want to care about the runtime configuration, except for `SecretSidecar` and I want Kustomize to figure the rest of the runtimes out for me, based on the catalog.

```yaml
# app/composition.yaml
kind: Composition
catalogs:
  - https://example.co/kustomize/catalog.yaml
modules:
# generate resources for a Java application
- apiVersion: example.com/v1
  kind: JavaApplication
  spec:
    application: team/my-app
    version: v1.0
- apiVersion: example.com/v1
  kind: Logger
  metadata:
    name: my-logger
  spec:
    logPath: /var/logs
- apiVersion: example.com/v1
  kind: SecretSidecar
  runtime: {container: {image: docker.example.co/module_providers/secrets:v0.9.0}}
  metadata:
    name: my-secrets
  spec:
    key: my.secret.value
    path: /etc/secrets
```

Unlike the previous execution of Kustomize, Kustomize will not use the catalog to resolve the `SecretSidecar`, as the runtime configuration was specified. 

#### Story 4

As a platform operator at Example Co, I want to provide an easier mechanism to enable use of the official Example Co Catalog. To do this, I compile a version of Kustomize with a built in reference to the Example Co official catalog. Example Co users can then simply reference our functions, without specifying the catalog:

```yaml
# app/composition.yaml
kind: Composition
modules:
# generate resources for a Java application
- apiVersion: example.com/v1
  kind: JavaApplication
  spec:
    application: team/my-app
    version: v1.0
- apiVersion: example.com/v1
  kind: Logger
  spec:
    logPath: /var/logs
- apiVersion: example.com/v1
  kind: SecretSidecar
  spec:
    key: my.secret.value
    path: /etc/secrets
```

#### Story 5

As a Kustomize developer, I want to build an `official` Helm extension module and publish it via the Kustomize official extension catalog. I build and publish the extension to the official Kustomize `gcr.io` project (or alternative, such as Github Package Registry). I then update the official Kustomize extension catalog:

```yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "official-kustomize-functions"
spec: 
  krmFunctions: 
  - group: kustomize.io
    names:
      kind: Helm
    description: "A Kustomize function that can handle Helm charts"
    versions:
    - name: v1
    runtime: 
      container: 
        image:  k8s.gcr.io/kustomize/helm-function:v1.0.0
```

This official extension will be embedded within the Kustomize binary and require subsequent releases to Kustomize when official extensions are updated. 

Alternatively, this could be published as an external resource that can be pulled by Kustomize as would any other catalog. This would decouple the release cadence of Kustomize and the official extensions, but would introduce extra latency for the end user.

#### Story 6

As a KRM function developer at company Example Co, I want to contribute a KRM function to the official extension catalog. 

I publish the implementation of my function as a container to a public Docker registry. I then contribute the necessary metadata to the public catalog, including:

* Runtime information
* Network access requirements
* Storage/volume requirements

Once this has been approved and included into the officially published catalog, my function is available for others to discover:

```yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "official-kustomize-functions"
spec: 
  krmFunctions: 
  - group: kustomize.io
    names:
      kind: Helm
    description: "A Kustomize function that can handle Helm charts"
    versions:
    - name: v1
    runtime: 
      container: 
        image:  k8s.gcr.io/kustomize/helm-function:v1.0.0
  - group: example.co
    names:
      kind: McGuffin
    description: "A KRM function that everyone is searching for"
    versions:
    - name: v1
    runtime: 
      container: 
        image:  docker.example.io/krm/mcguffin-function:v1.0.0
```

#### Story 7

As a platform developer at enterprise company Example Co, I wish to publish a trusted function catalog containing functions published by multiple sources, with appropriate metadata:

* One plugin developed by Banana Co   
* One plugin developed by Watermelon Co
* One plugin developed by my company Example Co

Using the runtime information and the metadata for each function, I publish a trusted catalog for use at Example Co

```yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "example-co-aggregated-catalog"
spec: 
  krmFunctions: 
  - group: banana.co
    names:
      kind: Split
    description: "A KRM function that splits a deployment into multiple deployments"
    versions:
    - name: v1
    runtime: 
      container: 
        image:  banana.gcr.io/functions/split-function:v1.0.0
  - group: watermelon.co
    names:
      kind: Salt
    description: "A KRM function that applies salt"
    versions:
    - name: v1
    runtime: 
      container: 
        image:  watermelon.gcr.io/krm-functions/salt-function:v1.0.0
  - group: example.com
    names:
      kind: JavaApplication
    description: "A Kustomize function that can handle Java apps"
    versions:
    - name: v1
    runtime: 
      container: 
        image: example/module_providers/java:v1.0.0
        requireNetwork: true
        requireFilesystem: true
```

### Notes/Constraints/Caveats (Optional)

Not all registries currently support OCI Artifacts, which will constrain the use of that capability. Most major cloud providers and several open source projects, however, support this:

* https://aws.amazon.com/blogs/containers/oci-artifact-support-in-amazon-ecr/
* https://cloud.google.com/artifact-registry
* https://docs.microsoft.com/en-us/azure/container-registry/container-registry-oci-artifacts
* https://github.com/features/packages
* https://github.com/goharbor/harbor/releases/tag/v2.0.0
* https://github.com/distribution/distribution

This proposal does not suggest adding any OCI artifact publishing capabilities to Kustomize, and would instead rely upon the [ORAS](https://oras.land) project to handle publishing and fetching of artifacts for now. Built in capabilities could be added by including ORAS as a library, but an analysis of the dependencies introduced will be needed.

### Risks and Mitigations

This proposal introduces extension capabilities to Kustomize that may expose users to external content. As with `Composition`, it must be made clear to users that use of a `Catalog` may represent untrusted/unvalidated content and they should only use `Catalogs` that they trust. When `Catalog` and other resources are stored as OCI artifacts, users can get extra assurance of content by using `digest` references. Additionally, the [cosign](https://github.com/sigstore/cosign) project could be used to provide signing and validation capabilities. The guidance around executing functions, as outlined in the [Composition](../2290-kustomize-plugin-composition/README.md) KEP remain applicable when combined with `Catalog` resources.

## Design Details

### Function Metadata Schema

The same function metadata will be used for both publishing KRM functions in
[the public function registry] and in the function catalog (this KEP).

[the public function registry]: https://github.com/kubernetes/enhancements/tree/master/keps/sig-cli/2906-kustomize-function-catalog

<details>
<summary>
Full OpenAPI schema
</summary>

```yaml
swagger: "2.0"
info:
  title: KRM Function Metadata
  version: v1alpha1
definitions:
  KRMFunctionDefinitionSpec:
    type: object
    description: spec contains the metadata for a KRM function.
    required:
      - group
      - names
      - description
      - publisher
      - versions
    properties:
      group:
        description: group of the functionConfig
        type: string
      description:
        description: brief description of the KRM function.
        type: string
      publisher:
        description: the entity (e.g. organization) that produced and owns this KRM function.
        type: string
      names:
        description: the resource and kind names for the KRM function
        type: object
        required:
        - kind
        properties:
          kind:
            description: the Kind of the functionConfig
            type: string
      versions:
        description: the versions of the functionConfig
        type: array
        items:
          type: object
          required:
            - name
            - schema
            - idempotent
            - runtime
            - usage
            - examples
            - license
          properties:
            name:
              description: Version of the functionConfig
              type: string
            schema:
              description: a URI pointing to the schema of the functionConfig
              type: object
              required:
                - openAPIV3Schema
              properties:
                openAPIV3Schema:
                  description: openAPIV3Schema is the OpenAPI v3 schema to use for validation
                  $ref: "#/definitions/io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1.JSONSchemaProps"
            idempotent:
              description: If the function is idempotent.
              type: boolean
            usage:
              description: |
                A URI pointing to a README.md that describe the details of how to
                use the KRM function. It should at least cover what the function
                does and what functionConfig does it support and it should give
                detailed explanation about each field in the functionConfig.
              type: string
            examples:
              description: |
                A list of URIs that point to README.md files. At least one example
                must be provided. Each README.md should cover an example. It
                should at least cover how to get input resources, how to run it
                and what is the expected output.
              type: array
              items:
                type: string
            license:
              description: The license of the KRM function.
              type: string
              enum:
                - Apache 2.0
            maintainers:
              description: |
                The maintainers for the function. It should only be used
                when the maintainers are different from the ones in
                `spec.maintainers`. When this field is specified, it
                override `spec.maintainers`.
              type: array
              items:
                type: string
            runtime:
              description: |
                The runtime information about the KRM function. At least one of 
                container and exec must be set.
              type: object
              properties:
                container:
                  description: The runtime information for container-based KRM function.
                  type: object
                  required:
                    - image
                  properties:
                    image:
                      description: The image name of the KRM function.
                      type: string
                    sha256:
                      description: |
                        The digest of the image that can be verified against. It
                        is required only when the image is using semver.
                      type: string
                    requireNetwork:
                      description: If network is required to run this function.
                      type: boolean
                    requireStorageMount:
                      description: If storage mount is required to run this function.
                      type: boolean
                exec:
                  description: The runtime information for exec-based KRM function.
                  type: object
                  required:
                    - platform
                  properties:
                    platforms:
                      description: Per platform runtime information.
                      type: array
                      items:
                        type: object
                        required:
                          - bin
                          - os
                          - arch
                          - uri
                          - sha256
                        properties:
                          bin:
                            description: The binary name.
                            type: string
                          os:
                            description: The target operating system to run the KRM function.
                            type: string
                            enum:
                              - linux
                              - darwin
                              - windows
                          arch:
                            description: The target architecture to run the KRM function.
                            type: string
                            enum:
                              - amd64
                              - arm64
                          uri:
                            description: The location to download the binary.
                            type: string
                          sha256:
                            description: The degist of the binary that can be used to verify the binary.
                            type: string
      home:
        description: A URI pointing the home page of the KRM function.
        type: string
      maintainers:
        description: The maintainers for the function.
        type: array
        items:
          type: string
      tags:
        description: |
          The tags (or keywords) of the function. e.g. mutator, validator,
          generator, prefix, GCP.
        type: array
        items:
          type: string
  KRMFunctionDefinition:
    type: object
    description: |
      KRMFunctionDefinition is metadata that defines a KRM function
      the same way a CustomResourceDefinition defines a custom resource.
    x-kubernetes-group-version-kind:
      - group: config.kubernetes.io
        kind: KRMFunctionDefinition
        version: v1alpha1
    required:
      - apiVersion
      - kind
      - spec
    properties:
      apiVersion:
        description: apiVersion of KRMFunctionDefinition. i.e. config.kubernetes.io/v1alpha1
        type: string
        enum:
          - config.kubernetes.io/v1alpha1
      kind:
        description: kind of the KRMFunctionDefinition. It must be KRMFunctionDefinition.
        type: string
        enum:
          - KRMFunctionDefinition
      spec:
        $ref: "#/definitions/KRMFunctionDefinitionSpec"
  KRMFunctionCatalog:
    type: object
    description: KRMFunctionCatalog is the metadata of a collection of KRM functions.
    x-kubernetes-group-version-kind:
      - group: config.kubernetes.io
        kind: KRMFunctionCatalog
        version: v1alpha1
    required:
      - apiVersion
      - kind
      - spec
    properties:
      apiVersion:
        description: apiVersion of KRMFunctionCatalog. i.e. config.kubernetes.io/v1alpha1
        type: string
        enum:
          - config.kubernetes.io/v1alpha1
      kind:
        description: kind of the KRMFunctionCatalog. It must be KRMFunctionCatalog.
        type: string
        enum:
          - KRMFunctionCatalog
      metadata:
        $ref: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json#io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"
      spec:
        type: object
        required:
          - krmFunctions
        properties:
          krmFunctions:
            type: array
            items:
              $ref: "#/definitions/KRMFunctionDefinitionSpec"
paths: {}
```
</details>

The catalog kind will have a YAML representation following the schema above. This representation will contain metadata about the catalog, such as name labels, as well as a collection of functions. Each function entry will contain an apiVersion and kind, along with one or more references to a function runtime (such as a container), as well as an optional information, such as Open API v3 definitions. Function runtime references can contain https, git, or OCI references. Additionally, a runtime can declare that it requires the use of network or storage mounts, which would otherwise be prohibited. The use of these requires [additional flags](https://github.com/kubernetes-sigs/kustomize/blob/1e1b9b484a836714b57b25c2cd47dda1780610e7/api/types/pluginrestrictions.go#L51-L55) on the command line. 

When using OCI references, either a tag or digest reference can be provided. Exec functions must include an sha256 hash for verification purposes, although this can also be done by using an OCI digest reference. When a hash verification fails, or a verification hash has not been provided, Kustomize will emit an error to inform the user.

An example representation is shown below:

```yaml
apiVersion: config.kubernetes.io/v1alpha1
kind: Catalog
metadata: 
  name: "example-co-functions"
  labels:
    author: ExampleCo
spec: 
  krmFunctions: 
  - group: example.com
    names:
      kind: SetNamespace
    description: "A short description of the KRM function"
    publisher: example.com
    versions:
      - name: v1
        schema:
          openAPIV3Schema: ... # inline schema like CRD
        idempotent: true|false
        runtime:
          container:
            image: docker.example.co/functions/set-namespace:v1.2.3
            sha256: a428de... # The digest of the image which can be verified against. This field is required if the version is semver.
            requireNetwork: true|false
            requireStorageMount: true|false
        usage: <a URL pointing to a README.md>
        examples:
          - <a URL pointing to a README.md>
          - <another URL pointing to another README.md>
        license: Apache 2.0
      - name: v1beta1
        ...
    maintainers: # The maintainers for this function. It doesn't need to be the same as the publisher OWNERS. 
      - foo@example.com
    tags: # keywords of the KRM functions
      - mutator
      - namespace
  - group: example.com
    kind: SetLogger
    description: "A short description of the KRM function"
    publisher: example.com
    versions:
      - name: v1
        schema:
          openAPIV3Schema: ...
        idempotent: true|false
        runtime:
          exec:
            platforms:
              - bin: foo-amd64-linux
                os: linux
                arch: amd64
                uri: https://example.com/foo-amd64-linux.tar.gz
                sha256: <hash>
              - bin: foo-amd64-darwin
                os: darwin
                arch: amd64
                uri: https://example.com/foo-amd64-darwin.tar.gz
                sha256: <hash>
        usage: <a URL pointing to a README.md>
        examples:
          - <a URL pointing to a README.md>
          - <another URL pointing to another README.md>
        license: Apache 2.0
      - name: v1beta1
        ...
    home: <a URL pointing to the home page>
    maintainers: # The maintainers for this function. It doesn't need to be the same as the publisher OWNERS. 
      - foo@example.com
    tags: # keywords of the KRM functions
      - mutator
```

### Determining the Function to Execute

When a `Composition`, or other Kustomize resource that utilizes funcions is loaded, Kustomize will leverage the `Catalog` to determine function runtimes that should be run. The order in which funcions are resolved is determined by the type of resource being processed, and will be clearly addressed in user facing documentation. When multiple catalogs are specified, they will be searched in the specified order. Within a catalog, the functions referenced will be searched in the specified order. This means that if two catalogs specify the same function, the first one referenced will be used. This also applies to a function being defined twice within a single catalog.

For a `Kustomization`, a catalog reference is local to a given layer and individual layers could reference different catalog or runtime versions. As the layer is processed, Kustomize will evaluate any catalog references and select the appropriate version based on the referenced catalog. 

For a `Composition`, on the other hand, `Kustomize` will consolidate the modules (functions) defined in the `Composition` and it's imports into a finalized list of modules. Next, it will consolidate the list of `Catalog`s in the module and it's imports to build a finalized list of `Catalog`s. Each of the `Catalog` resources will be fetched and used to build a unified catalog representation. When two catalogs define the same module, the first definition will be used.

Once the module list and the catalogs for the resolved composition have been generated, the following steps will be performed in order to determine the `runtime` to execute:

* If a KRM-style resource includes the `runtime` field, that will be used
* The `runtime` field will continue to support `container.image`, `starlark.path`, and `exec.path` options, for the time being. This short-circuits `Catalog` for the given function, and the flags currently required for function execution (`--enable-alpha-plugins`, `--enable-exec`) will continue to be required in this case.
* If the `runtime` field is absent, the configured `Catalog` resources will be used to determine the runtime to execute, based on the `kind` and `apiVersion` fields of the resource specification. If an official catalog has been created for Kustomize, it will be checked first.
* If there is no matching module, the processing of the resource will result in an error.

### Use of OCI Artifacts

<<[UNRESOLVED]>>
### OCI Artifacts

While this proposal is largely focused on the introduction of the new Catalog `kind`, the introduction of this kind enables additional distribution and trust mechanisms for non container based function runtimes and associated resources, like Open API v3 schemas through the use of OCI Artifacts. 

When OCI references are used, either a `tag` or `digest` reference can be used. This proposal does not address publishing functions or the `Catalog` resource to an OCI registry but will define the following media types, based on guidance in the [OCI Artifacts](https://github.com/opencontainers/artifacts/blob/master/artifact-authors.md#defining-a-unique-artifact-type) documentation:

| Description                 | Media Type                                                 | 
|-----------------------------|------------------------------------------------------------|
| Kustomize Catalog           | application/vnd.cncf.kubernetes.krm-func-catalog.layer.v1+yaml      |
| Kustomize Function Definition | application/vnd.cncf.kubernetes.krm-func-definition.layer.v1+yaml   |
| Kustomize Function (Starlark) | application/vnd.cncf.kubernetes.krm-func-runtime-starlark.layer.v1 |
| Kustomize Function (Exec)     | application/vnd.cncf.kubernetes.krm-func-runtime-starlark.layer.v1 |

The [ORAS](https://oras.land) library and CLI can be used to publish these artifacts and can be used to build specific publishing tooling, but Kustomize will not be changed to add publishing capabilities. Instead, appropriate user documentation and examples will be provided. 

In order to support pulling these resources, the ORAS library could be included as a dependency to support automatic fetching of OCI artifacts, however this will introduce a number of dependencies and could be undesirable. Alternatively, the ORAS binary can be installed by the user and used as the locally installed Docker client is used today. When an OCI artifact is referenced and fetched using ORAS, it will be stored locally within the file-system and can then be used within the `kustomize build` step. 

Kustomize function runtimes that are packaged as OCI images will continue to use the existing OCI media types. 

While out of scope of this KEP, the use of OCI artifacts enables additional verification use cases, like the signing and verification of function runtimes, definitions, and the catalog itself.
<<[/UNRESOLVED]>>

### Test Plan

 Kustomize already has a test harness capable of running functions, so this will be leveraged. Unit tests and end to end tests related to function and catalog retrieval, evaluation, and trust will be implemented, covering major workflows such as:
 * Retrieval of catalog resources
 * Resolving plug-in configuration references
 * Multiple catalog vs single catalog references
 * Use of containerized and non-containerized functions 

### Graduation Criteria

TBD

#### Alpha

- Feature integrated with the `kustomize build` command, and all currently implemented Kustomize kinds.
- Initial e2e tests completed and enabled
- Container based function runtime support.
- HTTPs and Git based catalog storage

#### Beta

- Gather feedback from developers and surveys
- Starlark and Exec function support
- OCI artifact support for catalog and runtime distribution

#### GA

- TBD


#### Deprecation

N/A 

### Upgrade / Downgrade Strategy

NA -- not part of the cluster

### Version Skew Strategy

NA -- not part of the cluster

## Production Readiness Review Questionnaire

NA -- not part of the cluster

### Feature Enablement and Rollback

This enhancement will only be available in the standalone kustomize command while it is in the alpha state. 

Integration and rollout to kubectl will not occur until the beta phase. 

### Rollout, Upgrade and Rollback Planning

NA -- distributed as a client-side binary

### Monitoring Requirements

NA -- distributed as a client-side binary

### Dependencies

The ability for kustomize, and by extension kubectl, to pull function runtimes specified in the catalog may introduce additional compile time or runtime dependencies. For example, pulling OCI artifacts is a net new capability and will either require the use of something like ORAS as a compile-time library dependency, or as a run-time client dependency like Docker. This will be examined as part of the work to move this enhancement to the beta state and a decision will be made based on an analysis of the dependencies that would be introduced.

This enhancement also introduces a dependency on catalogs and runtimes that may not be on the users local environment. When a catalog is unavailable and required for successful execution of kustomize build, an error will occur. If the catalog is referenced, but not actually required for the execution of kustomize build (i.e. no functions are actually used in a given kustomization or composition), the operation will complete successfully.

While most testing can occur without community infrastructure, we will require a place to publish and host catalog resources, along with functions, for testing purposes. We will investigate the use of Github registries or other Kubernetes community infrastructure to enable this. 

### Scalability

End users will encounter a cold-start period related to pulling the catalog resources and associated runtimes, if they do not exist locally on the file-system.

### Troubleshooting

NA -- distributed as a client-side binary

## Implementation History

2021-08-XX: Proposal submitted https://github.com/kubernetes/enhancements/pull/XXXX

## Drawbacks

The discovery mechanism imposed by this KEP does expose an additional layer of indirection/complexity for function users. Additionally, this will introduce some dependence on community infrastructure and may introduce some operational burden for function authors.  

## Alternatives

* Do nothing - as outlined in the drawbacks section, users can continue to leverage explicit references to runtimes, at the cost of module discoverability and ease of use.
* An alternative tool could be developed outside of kustomize that supports the catalog resource and installation of function runtimes, much like Krew does for kubectl functions. Such a tool would provide a less integrated experience and would require users to execute steps outside of the `kustomize build` flow and would need to modify the local Kustomize resources to add explicit runtime configuration.

## Infrastructure Needed (Optional)

When Kustomize publishes an official `Catalog` and any associated functions, the Kubernetes community GCR and GAR (if available) infrastructure will be needed to host resources.  

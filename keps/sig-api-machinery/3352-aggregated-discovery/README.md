<!-- **Note:** When your KEP is complete, all of these comment blocks
should be removed.

To get started with this template:

- [ ] **Pick a hosting SIG.** Make sure that the problem space is
  something the SIG is interested in taking up. KEPs should not be
  checked in without a sponsoring SIG.
- [ ] **Create an issue in kubernetes/enhancements** When filing an
  enhancement tracking issue, please make sure to complete all fields
  in that template. One of the fields asks for a link to the KEP. You
  can leave that blank until this KEP is filed, and then go back to
  the enhancement and add the link.
- [ ] **Make a copy of this template directory.** Copy this template
  into the owning SIG's directory and name it
  `NNNN-short-descriptive-title`, where `NNNN` is the issue number
  (with no leading-zero padding) assigned to your enhancement above.
- [ ] **Fill out as much of the kep.yaml file as you can.** At
  minimum, you should fill in the "Title", "Authors", "Owning-sig",
  "Status", and date-related fields.
- [ ] **Fill out this file as best you can.** At minimum, you should
  fill in the "Summary" and "Motivation" sections. These should be
  easy if you've preflighted the idea of the KEP with the appropriate
  SIG(s).
- [ ] **Create a PR for this KEP.** Assign it to people in the SIG who
  are sponsoring this process.
- [ ] **Merge early and iterate.** Avoid getting hung up on specific
  details and instead aim to get the goals of the KEP clarified and
  merged quickly. The best way to do this is to just start with the
  high-level sections and fill out details incrementally in subsequent
  PRs.

Just because a KEP is merged does not mean it is complete or approved.
Any KEP marked as `provisional` is a working document and subject to
change. You can denote sections that are under active debate as
follows:

``` <<[UNRESOLVED optional short context or usernames ]>> Stuff that
is being argued. <<[/UNRESOLVED]>> ```

When editing KEPS, aim for tightly-scoped, single-topic PRs to keep
discussions focused. If you disagree with what is already in a
document, open a new PR with suggested changes.

One KEP corresponds to one "feature" or "enhancement" for its whole
lifecycle. You do not need a new KEP to move from beta to GA, for
example. If new details emerge that belong in the KEP, edit the KEP.
Once a feature has become "implemented", major changes should get new
KEPs.

The canonical place for the latest set of instructions (and the likely
source of this file) is [here](/keps/NNNN-kep-template/README.md).

**Note:** Any PRs to move a KEP to `implementable`, or significant
changes once it is marked `implementable`, must be approved by each of
the KEP approvers. If none of those approvers are still appropriate,
then changes to that list should be approved by the remaining
approvers and/or the owning SIG (or SIG Architecture for cross-cutting
KEPs). -->
# KEP-3352: Aggregated Discovery

<!-- This is the title of your KEP. Keep it short, simple, and
descriptive. A good title can help communicate what the KEP is and
should be considered as part of any review. -->

<!-- A table of contents is helpful for quickly jumping to sections of
a KEP and for highlighting any additional information provided beyond
the standard KEP template.

Ensure the TOC is wrapped with <code>&lt;!-- toc --&rt;&lt;!-- /toc
  --&rt;</code> tags, and then generate with `hack/update-toc.sh`. -->

<!-- toc -->
- [Release Signoff Checklist](#release-signoff-checklist)
- [Summary](#summary)
- [Motivation](#motivation)
  - [Goals](#goals)
  - [Non-Goals](#non-goals)
- [Proposal](#proposal)
  - [Notes/Constraints/Caveats (Optional)](#notesconstraintscaveats-optional)
  - [Risks and Mitigations](#risks-and-mitigations)
- [Design Details](#design-details)
  - [API](#api)
  - [Aggregation](#aggregation)
  - [Client](#client)
  - [Test Plan](#test-plan)
      - [Prerequisite testing updates](#prerequisite-testing-updates)
      - [Unit tests](#unit-tests)
      - [Integration tests](#integration-tests)
      - [e2e tests](#e2e-tests)
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
<!-- /toc -->

## Release Signoff Checklist

<!-- **ACTION REQUIRED:** In order to merge code into a release, there
must be an issue in [kubernetes/enhancements] referencing this KEP and
targeting a release milestone **before the [Enhancement
Freeze](https://git.k8s.io/sig-release/releases) of the targeted
release**.

For enhancements that make changes to code or processes/procedures in
core Kubernetes—i.e., [kubernetes/kubernetes], we require the
following Release Signoff checklist to be completed.

Check these off as they are completed for the Release Team to track.
These checklist items _must_ be updated for the enhancement to be
released. -->

Items marked with (R) are required *prior to targeting to a milestone
/ release*.

- [ ] (R) Enhancement issue in release milestone, which links to KEP
      dir in [kubernetes/enhancements] (not the initial KEP PR)
- [ ] (R) KEP approvers have approved the KEP status as
      `implementable`
- [ ] (R) Design details are appropriately documented
- [ ] (R) Test plan is in place, giving consideration to SIG
      Architecture and SIG Testing input (including test refactors)
  - [ ] e2e Tests for all Beta API Operations (endpoints)
  - [ ] (R) Ensure GA e2e tests for meet requirements for [Conformance
        Tests](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/conformance-tests.md)
  - [ ] (R) Minimum Two Week Window for GA e2e tests to prove flake
        free
- [ ] (R) Graduation criteria is in place
  - [ ] (R) [all GA
        Endpoints](https://github.com/kubernetes/community/pull/1806)
        must be hit by [Conformance
        Tests](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/conformance-tests.md)
- [ ] (R) Production readiness review completed
- [ ] (R) Production readiness review approved
- [ ] "Implementation History" section is up-to-date for milestone
- [ ] User-facing documentation has been created in
      [kubernetes/website], for publication to [kubernetes.io]
- [ ] Supporting documentation—e.g., additional design documents,
      links to mailing list discussions/SIG meetings, relevant
      PRs/issues, release notes

<!-- **Note:** This checklist is iterative and should be reviewed and
updated every time this enhancement is being considered for a
milestone. -->

[kubernetes.io]: https://kubernetes.io/
[kubernetes/enhancements]: https://git.k8s.io/enhancements
[kubernetes/kubernetes]: https://git.k8s.io/kubernetes
[kubernetes/website]: https://git.k8s.io/website

## Summary

<!-- This section is incredibly important for producing high-quality,
user-focused documentation such as release notes or a development
roadmap. It should be possible to collect this information before
implementation begins, in order to avoid requiring implementors to
split their attention between writing release notes and implementing
the feature itself. KEP editors and SIG Docs should help to ensure
that the tone and content of the `Summary` section is useful for a
wide audience.

A good summary is probably at least a paragraph in length.

Both in this section and below, follow the guidelines of the
[documentation style guide]. In particular, wrap lines to a reasonable
length, to make it easier for reviewers to cite specific portions, and
to minimize diff churn on updates.
-->


The operations that a Kubernetes API server supports are reported
through a collection of small documents partitioned by group-version.
All clients of Kubernetes APIs must send a request to every
group-version in order to "discover" the available APIs. This causes a
storm of requests for clusters and is a source of latency and
throttling. This KEP proposes centralizing the "discovery" mechanism
into one document so that clients only need to make one request to the
API server to retrieve all the operations available.

## Motivation

<!-- This section is for explicitly listing the motivation, goals, and
non-goals of this KEP. Describe why the change is important and the
benefits to users. The motivation section can optionally provide links
to [experience reports] to demonstrate the interest in a KEP within
the wider Kubernetes community.

[experience reports]: https://github.com/golang/go/wiki/ExperienceReports -->

All clients and users of Kubernetes APIs usually first need to
“discover” what the available APIs are and how they can be used. These
APIs are described through a mechanism called “Discovery” which is
typically queried to then build the requests to correct APIs.
Unfortunately, the “Discovery” API is made of lots of small objects
that need to be queried individually, causing possibly a lot of delay
due to the latency of each individual request (up to 80 requests, with
most objects being less than 1,024 bytes). The more numerous the APIs
provided by the Kubernetes cluster, the more requests need to be
performed.

The most well known Kubernetes client that uses the discovery
mechanism is `kubectl`, and more specifically the
`CachedDiscoveryClient` in `client-go`. To mitigate some of this
latency, kubectl has implemented a 6 hour timer during which the
discovery API is not refreshed. The drawback of this approach is that
the freshness of the cache is doubtful and the entire discovery API
needs to be refreshed after 6 hours, even if it hasn’t expired.

This not only impacts kubectl, but all clients of kubernetes. We can
do better.

### Goals

- Fix the discovery storm issue currently present in kubectl
- Aggregate the discovery documents for all Kubernetes types

<!-- List the specific goals of the KEP. What is it trying to achieve?
How will we know that this has succeeded? -->

### Non-Goals

<!-- What is out of scope for this KEP? Listing non-goals helps to
focus discussion and make progress. -->

Since the current discovery separated by group-version is already GA,
removal of the endpoint will not be attempted. There are still use
cases for publishing the discovery document per group-version and this
KEP will solely focus on introducing the new aggregated endpoint.

## Proposal

We are proposing a new endpoint `/discovery/v1` as an aggregated
endpoint for all discovery documents. Discovery documents can
currently be found under `apis/<group>/<version>` and `/api/v1` for
the legacy group version. This discovery endpoint will support
publishing an ETag so clients who already have the latest version of
the aggregated discovery can avoid redownloading the document.

We will add a new controller responsible for aggregating the discovery
documents when a resource on the cluster changes. There will be no
conflicts when aggregating since each discovery document is
self-contained.

### Notes/Constraints/Caveats (Optional)

<!-- What are the caveats to the proposal? What are some important
details that didn't come across above? Go in to as much detail as
necessary here. This might be a good place to talk about core concepts
and how they relate. -->

### Risks and Mitigations

<!-- What are the risks of this proposal, and how do we mitigate?
Think broadly. For example, consider both security and how this will
impact the larger Kubernetes ecosystem.

How will security be reviewed, and by whom?

How will UX be reviewed, and by whom?

Consider including folks who also work outside the SIG or subproject.
-->

## Design Details

<!-- This section should contain enough information that the specifics
of your change are understandable. This may include API specs (though
not always required) or even code snippets. If there's any ambiguity
about HOW your proposal will be implemented, this is the place to
discuss them. -->

We will expose a endpoint `/discovery` that will support JSON, and
protobuf and gzip compression. The endpoint will serve the aggregated
discovery document for all types that a Kubernetes cluster supports.

### API

The contents of this endpoint will be an `APIGroupList`, which is the
same type that is returned in the discovery document at `/apis`. The
`APIGroupList` contains a list of `APIGroup` types which includes a
list of
[`GroupVersionForDiscovery`](https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go#L1071)
types. We will modify this `GroupVersionForDiscovery` type to include
a list of
[`APIResource`](https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go#L1080).
This list of `APIResource` is what is currently published at the
`/apis/<group>/version` endpoint and is what will be aggregated into
the new endpoint that we publish.

The endpoint will also publish an ETag calculated based on a hash of
the data for clients.

This is approximately what the new API will look like (conflicting names will be renamed)

```go
// APIGroupList is a list of APIGroup, to allow clients to discover the API at
// /apis.
type APIGroupList struct {
	TypeMeta `json:",inline"`
	// groups is a list of APIGroup.
	Groups []APIGroup `json:"groups" protobuf:"bytes,1,rep,name=groups"`
}

// APIGroup contains the name, the supported versions, and the preferred version
// of a group.
type APIGroup struct {
	TypeMeta `json:",inline"`
	// name is the name of the group.
	Name string `json:"name" protobuf:"bytes,1,opt,name=name"`
	// versions are the versions supported in this group.
	// This will be sorted in descending order based on the preferred version
	Versions []GroupVersionForDiscovery `json:"versions" protobuf:"bytes,2,rep,name=versions"`
	// PreferredVersion will be removed for the new Discovery API
	// The GroupVersionForDiscovery will be sorted based on the preferred version
	// PreferredVersion GroupVersionForDiscovery `json:"preferredVersion,omitempty" protobuf:"bytes,3,opt,name=preferredVersion"`

 	// ServerAddresssByClientCIDRs will be removed for the new Discovery API
	//ServerAddressByClientCIDRs []ServerAddressByClientCIDR `json:"serverAddressByClientCIDRs,omitempty" protobuf:"bytes,4,rep,name=serverAddressByClientCIDRs"`
}

// GroupVersion contains the "group/version" and "version" string of a version.
// It is made a struct to keep extensibility.
type GroupVersionForDiscovery struct {
	// groupVersion specifies the API group and version in the form "group/version"
	// This will be removed for the new discovery
	// GroupVersion string `json:"groupVersion" protobuf:"bytes,1,opt,name=groupVersion"`
	// version specifies the version in the form of "version". This is to save
	// the clients the trouble of splitting the GroupVersion.
	Version string `json:"version" protobuf:"bytes,2,opt,name=version"`
	// resources contains the name of the resources and if they are namespaced.
	APIResources []APIResource `json:"resources" protobuf:"bytes,2,rep,name=resources"`

 	// LastContacted is the last time that the apiserver has successfully reached the
 	// corresponding group version's discovery document. This will be nil if the group-version
 	// has not been aggregated yet (APIResources will be empty). To maintain consistency across scenarios with multiple
 	// apiservers, this time will be quantized down to the nearest fifteen minutes.
 	LastContacted *time.Time `json:"lastContacted" protobuf:"bytes,opt,name=lastContacted"`
}

// APIResource specifies the name of a resource and whether it is namespaced.
type APIResource struct {
	// name is the plural name of the resource.
	Name string `json:"name" protobuf:"bytes,1,opt,name=name"`
	// singularName is the singular name of the resource.  This allows clients to handle plural and singular opaquely.
	// The singularName is more correct for reporting status on a single item and both singular and plural are allowed
	// from the kubectl CLI interface.
	SingularName string `json:"singularName" protobuf:"bytes,6,opt,name=singularName"`
	// namespaced indicates if a resource is namespaced or not.
	Namespaced bool `json:"namespaced" protobuf:"varint,2,opt,name=namespaced"`
	// group is the preferred group of the resource.  Empty implies the group of the containing resource list.
	// For subresources, this may have a different value, for example: Scale".
	Group string `json:"group,omitempty" protobuf:"bytes,8,opt,name=group"`
	// version is the preferred version of the resource.  Empty implies the version of the containing resource list
	// For subresources, this may have a different value, for example: v1 (while inside a v1beta1 version of the core resource's group)".
	Version string `json:"version,omitempty" protobuf:"bytes,9,opt,name=version"`
	// kind is the kind for the resource (e.g. 'Foo' is the kind for a resource 'foo')
	Kind string `json:"kind" protobuf:"bytes,3,opt,name=kind"`
	// verbs is a list of supported kube verbs (this includes get, list, watch, create,
	// update, patch, delete, deletecollection, and proxy)
	Verbs Verbs `json:"verbs" protobuf:"bytes,4,opt,name=verbs"`
	// shortNames is a list of suggested short names of the resource.
	ShortNames []string `json:"shortNames,omitempty" protobuf:"bytes,5,rep,name=shortNames"`
	// categories is a list of the grouped resources this resource belongs to (e.g. 'all')
	Categories []string `json:"categories,omitempty" protobuf:"bytes,7,rep,name=categories"`

 	// StorageVersionHash will be removed in the new Discovery API
	// StorageVersionHash string `json:"storageVersionHash,omitempty" protobuf:"bytes,10,opt,name=storageVersionHash"`
}
```

### Aggregation

For the aggregation layer on the server, a new controller will be
created to aggregate discovery for built-in types, apiextensions types
(CRDs), and types from aggregated api servers.

A post start hook will be added and the kube-apiserver health check
should only pass if the discovery document is ready. Since aggregated
api servers may take longer to respond and we do not want to delay
cluster startup, the health check will only block on the local api
servers (built-ins and CRDs) to have their discovery ready. For api
servers that have not been aggregated, their group-versions will be
published with an empty resource list and a null value for
`lastContacted` to indicate that they have not synced yet.

### Client

The `client-go` interface will be modified to add a new method to
retrieve the aggregated discovery document and `kubectl` will be the
initial candidate. As a starting point, `kubectl api-resources` should
use the aggregated discovery document instead of sending a storm of
requests.

### Test Plan

<!-- **Note:** *Not required until targeted at a release.* The goal is
to ensure that we don't accept enhancements with inadequate testing.

All code is expected to have adequate tests (eventually with coverage
expectations). Please adhere to the [Kubernetes testing
guidelines][testing-guidelines] when drafting this test plan.

[testing-guidelines]: https://git.k8s.io/community/contributors/devel/sig-testing/testing.md -->

[x] I/we understand the owners of the involved components may require
updates to existing tests to make this code solid enough prior to
committing the changes necessary to implement this enhancement.

##### Prerequisite testing updates

<!-- Based on reviewers feedback describe what additional tests need
to be added prior implementing this enhancement to ensure the
enhancements have also solid foundations. -->

##### Unit tests

<!-- In principle every added code should have complete unit test
coverage, so providing the exact set of tests will not bring
additional value. However, if complete unit test coverage is not
possible, explain the reason of it together with explanation why this
is acceptable. -->

<!-- Additionally, for Alpha try to enumerate the core package you
will be touching to implement this enhancement and provide the current
unit coverage for those in the form of:
- <package>: <date> - <current test coverage> The data can be easily
read from:
https://testgrid.k8s.io/sig-testing-canaries#ci-kubernetes-coverage-unit

This can inform certain test coverage improvements that we want to do
before extending the production code to implement this enhancement.
-->

This will be implemented in a new package in kube-aggregator.

##### Integration tests

<!-- This question should be filled when targeting a release. For
Alpha, describe what tests will be added to ensure proper quality of
the enhancement.

For Beta and GA, add links to added tests together with links to
k8s-triage for those tests:
https://storage.googleapis.com/k8s-triage/index.html -->

For alpha, integration tests will be added to exercise the new
aggregated discovery code path.

##### e2e tests

<!-- This question should be filled when targeting a release. For
Alpha, describe what tests will be added to ensure proper quality of
the enhancement.

For Beta and GA, add links to added tests together with links to
k8s-triage for those tests:
https://storage.googleapis.com/k8s-triage/index.html

We expect no non-infra related flakes in the last month as a GA
graduation criteria. -->

For alpha, tests will be added to exercise the new aggregated
discovery code path for kubectl, both on the server and client side.

### Graduation Criteria

<!-- **Note:** *Not required until targeted at a release.*

Define graduation milestones.

These may be defined in terms of API maturity, [feature gate]
graduations, or as something else. The KEP should keep this high-level
with a focus on what signals will be looked at to determine
graduation.

Consider the following in developing the graduation criteria for this
enhancement:
- [Maturity levels (`alpha`, `beta`, `stable`)][maturity-levels]
- [Feature gate][feature gate] lifecycle
- [Deprecation policy][deprecation-policy]

Clearly define what graduation means by either linking to the [API doc
definition](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#api-versioning)
or by redefining what graduation means.

In general we try to use the same stages (alpha, beta, GA), regardless
of how the functionality is accessed.

[feature gate]: https://git.k8s.io/community/contributors/devel/sig-architecture/feature-gates.md
[maturity-levels]: https://git.k8s.io/community/contributors/devel/sig-architecture/api_changes.md#alpha-beta-and-stable-versions
[deprecation-policy]: https://kubernetes.io/docs/reference/using-api/deprecation-policy/

Below are some examples to consider, in addition to the aforementioned
[maturity levels][maturity-levels]. -->

#### Alpha

- Feature implemented behind a feature flag
- Initial e2e tests completed and enabled
- At least one client (kubectl) has an implementation to use the
  aggregated discovery feature

#### Beta

- kubectl uses the aggregated discovery feature by default

#### GA

- TBD

**Note:** Generally we also wait at least two releases between beta
and GA/stable, because there's no opportunity for user feedback, or
even bug reports, in back-to-back releases.

**For non-optional features moving to GA, the graduation criteria must
include [conformance tests].**

[conformance tests]: https://git.k8s.io/community/contributors/devel/sig-architecture/conformance-tests.md

#### Deprecation


### Upgrade / Downgrade Strategy

Aggregated discovery will be behind a feature gate. It is an in-memory
feature and upgrade/downgrade is not a problem.

### Version Skew Strategy

## Production Readiness Review Questionnaire

<!--

Production readiness reviews are intended to ensure that features
merging into Kubernetes are observable, scalable and supportable; can
be safely operated in production environments, and can be disabled or
rolled back in the event they cause increased failures in production.
See more in the PRR KEP at
https://git.k8s.io/enhancements/keps/sig-architecture/1194-prod-readiness.

The production readiness review questionnaire must be completed and
approved for the KEP to move to `implementable` status and be included
in the release.

In some cases, the questions below should also have answers in
`kep.yaml`. This is to enable automation to verify the presence of the
review, and to reduce review burden and latency.

The KEP must have a approver from the
[`prod-readiness-approvers`](http://git.k8s.io/enhancements/OWNERS_ALIASES)
team. Please reach out on the
[#prod-readiness](https://kubernetes.slack.com/archives/CPNHUMN74)
channel if you need any help or guidance. -->

### Feature Enablement and Rollback

<!-- This section must be completed when targeting alpha to a release.
-->

###### How can this feature be enabled / disabled in a live cluster?

- [x] Feature gate (also fill in values in `kep.yaml`)
  - Feature gate name: AggregatedDiscovery
  - Components depending on the feature gate: kube-apiserver

###### Does enabling the feature change any default behavior?

No

###### Can the feature be disabled once it has been enabled (i.e. can we roll back the enablement)?

<!-- Describe the consequences on existing workloads (e.g., if this is
a runtime feature, can it break the existing applications?).

Feature gates are typically disabled by setting the flag to `false`
and restarting the component. No other changes should be necessary to
disable the feature.

NOTE: Also set `disable-supported` to `true` or `false` in `kep.yaml`.
--> Yes, the feature may be disabled by reverting the feature flag.

###### What happens if we reenable the feature if it was previously rolled back?

The feature does not depend on state, and can be disabled/enabled at
will.

###### Are there any tests for feature enablement/disablement?

<!-- The e2e framework does not currently support enabling or
disabling feature gates. However, unit tests in each component dealing
with managing data, created with and without the feature, are
necessary. At the very least, think about conversion tests if API
types are being modified.

Additionally, for features that are introducing a new API field, unit
tests that are exercising the `switch` of feature gate itself (what
happens if I disable a feature gate after having objects written with
the new field) are also critical. You can take a look at one potential
example of such test in:
https://github.com/kubernetes/kubernetes/pull/97058/files#diff-7826f7adbc1996a05ab52e3f5f02429e94b68ce6bce0dc534d1be636154fded3R246-R282
-->

A test will be added to ensure that the RESTMapper functionality works
properly both when the feature is enabled and disabled.

### Rollout, Upgrade and Rollback Planning

<!-- This section must be completed when targeting beta to a release.
-->

###### How can a rollout or rollback fail? Can it impact already running workloads?

<!-- Try to be as paranoid as possible - e.g., what if some components
will restart mid-rollout?

Be sure to consider highly-available clusters, where, for example,
feature flags will be enabled on some API servers and not others
during the rollout. Similarly, consider large clusters and how
enablement/disablement will rollout across nodes. -->

###### What specific metrics should inform a rollback?

<!-- What signals should users be paying attention to when the feature
is young that might indicate a serious problem? -->

High latency or failure of a metric in the newly added discovery
aggregation controller. If the `/discovery/v1` endpoint is not
reachable or if there are errors from the endpoint, that could be a
sign of rollback as well.


###### Were upgrade and rollback tested? Was the upgrade->downgrade->upgrade path tested?

<!-- Describe manual testing that was done and the outcomes. Longer
term, we may want to require automated upgrade/rollback tests, but we
are missing a bunch of machinery and tooling and can't do that now.
-->

###### Is the rollout accompanied by any deprecations and/or removals of features, APIs, fields of API types, flags, etc.?

<!-- Even if applying deprecation policies, they may still surprise
some users. -->

### Monitoring Requirements

<!-- This section must be completed when targeting beta to a release.

For GA, this section is required: approvers should be able to confirm
the previous answers based on experience in the field. -->

###### How can an operator determine if the feature is in use by workloads?

<!-- Ideally, this should be a metric. Operations against the
Kubernetes API (e.g., checking if there are objects with field X set)
may be a last resort. Avoid logs or events for this purpose. -->

###### How can someone using this feature know that it is working for their instance?

<!-- For instance, if this is a pod-related feature, it should be
possible to determine if the feature is functioning properly for each
individual pod. Pick one more of these and delete the rest. Please
describe all items visible to end users below with sufficient detail
so that they can verify correct enablement and operation of this
feature. Recall that end users cannot usually observe component logs
or access metrics. -->

`/discovery/v1` endpoint is populated with discovery information, and all expected group-versions are present.

###### What are the reasonable SLOs (Service Level Objectives) for the enhancement?

<!-- This is your opportunity to define what "normal" quality of
service looks like for a feature.

It's impossible to provide comprehensive guidance, but at the very
high level (needs more precise definitions) those may be things like:
  - per-day percentage of API calls finishing with 5XX errors <= 1%
  - 99% percentile over day of absolute value from (job creation time
    minus expected job creation time) for cron job <= 10%
  - 99.9% of /health requests per day finish with 200 code

These goals will help you determine what you need to measure (SLIs) in
the next question. -->

###### What are the SLIs (Service Level Indicators) an operator can use to determine the health of the service?

<!-- Pick one more of these and delete the rest. -->

- [x] Metrics
  - Metric name: `aggregator_discovery_aggregation_duration`
  - Components exposing the metric: `kube-server`
  - This is a metric for exposing the time it took to aggregate all the

###### Are there any missing metrics that would be useful to have to improve observability of this feature?

<!-- Describe the metrics themselves and the reasons why they weren't
added (e.g., cost, implementation difficulties, etc.). -->

Yes. A metric for the regeneration count of the discovery document. `aggregator_discovery_aggregation_count`

### Dependencies

<!-- This section must be completed when targeting beta to a release.
-->

###### Does this feature depend on any specific services running in the cluster?

<!-- Think about both cluster-level services (e.g. metrics-server) as
well as node-level agents (e.g. specific version of CRI). Focus on
external or optional services that are needed. For example, if this
feature depends on a cloud provider API, or upon an external
software-defined storage or network control plane.

For each of these, fill in the following—thinking about running
existing user workloads and creating new ones, as well as about
cluster-level services (e.g. DNS):
  - [Dependency name]
    - Usage description:
      - Impact of its outage on the feature:
      - Impact of its degraded performance or high-error rates on the
feature: -->

### Scalability

<!-- For alpha, this section is encouraged: reviewers should consider
these questions and attempt to answer them.

For beta, this section is required: reviewers must answer these
questions.

For GA, this section is required: approvers should be able to confirm
the previous answers based on experience in the field. -->

###### Will enabling / using this feature result in any new API calls?

<!-- Describe them, providing:
  - API call type (e.g. PATCH pods)
  - estimated throughput
  - originating component(s) (e.g. Kubelet, Feature-X-controller)
Focusing mostly on:
  - components listing and/or watching resources they didn't before
  - API calls that may be triggered by changes of some Kubernetes
    resources (e.g. update of object X triggers new updates of object
    Y)
  - periodic API calls to reconcile state (e.g. periodic fetching
    state, heartbeats, leader election, etc.) -->

###### Will enabling / using this feature result in introducing new API types?

<!-- Describe them, providing:
  - API type
  - Supported number of objects per cluster
  - Supported number of objects per namespace (for namespace-scoped
objects) -->

###### Will enabling / using this feature result in any new calls to the cloud provider?

<!-- Describe them, providing:
  - Which API(s):
  - Estimated increase: -->

###### Will enabling / using this feature result in increasing size or count of the existing API objects?

<!-- Describe them, providing:
  - API type(s):
  - Estimated increase in size: (e.g., new annotation of size 32B)
  - Estimated amount of new objects: (e.g., new Object X for every
existing Pod) -->

###### Will enabling / using this feature result in increasing time taken by any operations covered by existing SLIs/SLOs?

<!-- Look at the [existing SLIs/SLOs].

Think about adding additional work or introducing new steps in between
(e.g. need to do X to start a container), etc. Please describe the
details.

[existing SLIs/SLOs]: https://git.k8s.io/community/sig-scalability/slos/slos.md#kubernetes-slisslos -->

###### Will enabling / using this feature result in non-negligible increase of resource usage (CPU, RAM, disk, IO, ...) in any components?

<!-- Things to keep in mind include: additional in-memory state,
additional non-trivial computations, excessive access to disks
(including increased log volume), significant amount of data sent
and/or received over network, etc. This through this both in small and
large cases, again with respect to the [supported limits].

[supported limits]: https://git.k8s.io/community//sig-scalability/configs-and-limits/thresholds.md -->

### Troubleshooting

<!-- This section must be completed when targeting beta to a release.

For GA, this section is required: approvers should be able to confirm
the previous answers based on experience in the field.

The Troubleshooting section currently serves the `Playbook` role. We
may consider splitting it into a dedicated `Playbook` document
(potentially with some monitoring details). For now, we leave it here.
-->

###### How does this feature react if the API server and/or etcd is unavailable?

###### What are other known failure modes?

<!-- For each of them, fill in the following information by copying
the below template:
  - [Failure mode brief description]
    - Detection: How can it be detected via metrics? Stated another
      way: how can an operator troubleshoot without logging into a
      master or worker node?
    - Mitigations: What can be done to stop the bleeding, especially
      for already running user workloads?
    - Diagnostics: What are the useful log messages and their required
      logging levels that could help debug the issue? Not required
      until feature graduated to beta.
    - Testing: Are there any tests for failure mode? If not, describe
why. -->

###### What steps should be taken if SLOs are not being met to determine the problem?

## Implementation History

<!-- Major milestones in the lifecycle of a KEP should be tracked in
this section. Major milestones might include:
- the `Summary` and `Motivation` sections being merged, signaling SIG
  acceptance
- the `Proposal` section being merged, signaling agreement on a
  proposed design
- the date implementation started
- the first Kubernetes release where an initial version of the KEP was
  available
- the version of Kubernetes where the KEP graduated to general
  availability
- when the KEP was retired or superseded -->

## Drawbacks

With aggregation, the size of the aggregated discovery document could
be an issue in the future since clients will need to download the
entire document on any resource update. At the moment, even with 3000
CRDs (already very unlikely), the total size is still smaller than
1MB.

## Alternatives

<!-- What other approaches did you consider, and why did you rule them
out? These do not need to be as detailed as the proposal, but should
include enough information to express the idea and why it was not
acceptable. -->

An alternative that was considered is [Discovery Cache
Busting](https://docs.google.com/document/d/1AulBtUYjVcc4s809YSQq4bdRdDO3byY7ew9za4Ortj4).
Cache-busting allows clients to know if the files need to be
downloaded at all, and in most cases the download can be skipped
entirely. This typically works by including a hash of the resource
content in its name, while marking the objects as never-expiring using
cache control headers. Clients can then recognize if the names have
changed or stayed the same, and re-use files that have kept the same
name without downloading them again.

Aggregated Discovery was selected because of the amount of requests that are saved both on startup and on changes involving multiple group versions. For a full comparison between Discovery Cache Busting and Aggregated Discovery, please refer to the [Google Doc](https://docs.google.com/document/d/1sdf8nz5iTi86ErQy9OVxvQh_0RWfeU3Vyu0nlA10LNM).

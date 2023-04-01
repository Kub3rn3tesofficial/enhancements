# KEP-785: Scheduler Component Config API

<!-- toc -->
- [Release Signoff Checklist](#release-signoff-checklist)
- [Summary](#summary)
- [Motivation](#motivation)
  - [Goals](#goals)
  - [Non-Goals](#non-goals)
- [Proposal](#proposal)
  - [Risks and Mitigations](#risks-and-mitigations)
- [Design Details](#design-details)
  - [Test Plan](#test-plan)
      - [Prerequisite testing updates](#prerequisite-testing-updates)
      - [Unit tests](#unit-tests)
      - [Integration tests](#integration-tests)
      - [e2e tests](#e2e-tests)
  - [Graduation Criteria](#graduation-criteria)
    - [Alpha -&gt; Beta Graduation](#alpha---beta-graduation)
    - [Beta -&gt; GA Graduation](#beta---ga-graduation)
  - [Upgrade/Downgrade Strategy](#upgradedowngrade-strategy)
  - [Version Skew Strategy](#version-skew-strategy)
- [Production Readiness Review Questionnaire](#production-readiness-review-questionnaire)
  - [Feature enablement and rollback](#feature-enablement-and-rollback)
  - [Rollout, Upgrade and Rollback Planning](#rollout-upgrade-and-rollback-planning)
  - [Monitoring requirements](#monitoring-requirements)
  - [Dependencies](#dependencies)
  - [Scalability](#scalability)
  - [Troubleshooting](#troubleshooting)
- [Implementation History](#implementation-history)
<!-- /toc -->

## Release Signoff Checklist

- [x] (R) Enhancement issue in release milestone, which links to KEP dir in [kubernetes/enhancements] (not the initial KEP PR)
- [x] (R) KEP approvers have approved the KEP status as `implementable`
- [x] (R) Design details are appropriately documented
- [x] (R) Test plan is in place, giving consideration to SIG Architecture and SIG Testing input
- [x] (R) Graduation criteria is in place
- [x] (R) Production readiness review completed
- [x] Production readiness review approved
- [x] "Implementation History" section is up-to-date for milestone
- [x] User-facing documentation has been created in [kubernetes/website], for publication to [kubernetes.io]
- [ ] Supporting documentation e.g., additional design documents, links to mailing list discussions/SIG meetings, relevant PRs/issues, release notes

[kubernetes.io]: https://kubernetes.io/
[kubernetes/enhancements]: https://git.k8s.io/enhancements
[kubernetes/kubernetes]: https://git.k8s.io/kubernetes
[kubernetes/website]: https://git.k8s.io/website

## Summary

The kube-scheduler configuration API `kubescheduler.config.k8s.io` was in alpha
for several releases. We graduated it to beta in 1.19 as `v1beta1`. We introduced
`v1beta2` and `v1beta3` in 1.22 and 1.23 respectively. And it was graduated to GA
in 1.25 as `v1`. The `v1beta2` was marked as deprecated in 1.25 and will be removed 
in 1.28. `v1beta3` will be marked as deprecated in 1.26 and removed in 1.29.

## Motivation

The `kubescheduler.config.k8s.io` API has been in alpha stage for several
releases. In release 1.18, we introduced `v1alpha2`, including important
changes such as:

- The removal of the old Policy API in favor of plugin configurations, that
  align with the new scheduler framework.
- The introduction of scheduling profiles, that allow a scheduler to appear
  as multiple schedulers under different configurations.

A configuration API allows cluster administrators to build, validate and
version their configurations in a more robust way than using command line flags.

Graduating this API to Beta is a sign of its maturity that would encourage wider
usage.

### Goals

- Introduce `kubescheduler.config.k8s.io/v1beta1` as a copy of
`kubescheduler.config.k8s.io/v1alpha2` with minimal cleanup changes.
- Iterate the API in `kubescheduler.config.k8s.io/v1beta2`, `kubescheduler.config.k8s.io/v1beta3` based on learnings.
- Use the newly created API objects to build the default configuration for kube-scheduler.

### Non-Goals

- Update configuration scripts in /cluster to use API.

## Proposal

For the most part, `kubescheduler.config.k8s.io/v1beta1` will be a copy of
`kubescheduler.config.k8s.io/v1alpha2`, with the following differences:

- [ ] `.bindTimeoutSeconds` will be an argument for `VolumeBinding` plugin.
- [ ] `.profiles[*].plugins.unreserve` will be removed.
- [ ] Embedded types of `RequestedToCapacityRatio` will include missing json tags
  and will be decoded with a case-sensitive decoder.

The second iteration, `kubescheduler.config.k8s.io/v1beta2`, includes the following changes:
  - Plugin removals:
    - `NodeLabel` (in favor of `NodeAffinity`)
    - `ServiceAffinity` (in favor of `NodeAffinity`)
    - `NodePreferAvoidPods` (in favor of `TaintToleration`)
    - `NodeResourcesLeastAllocated` (in favor of `NodeResourcesFit` plugin with a `LeastAllocated` scoring strategy)
    - `NodeResourcesMostAllocated` (in favor of `NodeResourcesFit` plugin with a `MostAllocated` scoring strategy)
    - `RequestedToCapacityRatio` (in favor of `NodeResourcesFit` plugin with a `RequestedToCapacityRatio` scoring strategy)
  - Cleanup of validation hacks.

The third iteration, `kubescheduler.config.k8s.io/v1beta3`, includes the following changes:
  - Change the weight of plugins that can be influenced by end users through the Pod specs.
    - `InterPodAffinity` to 2
    - `NodeAffinity` to 2
    - `TaintToleration` to 3 as leveraging node tainting to group nodes in the cluster is becoming a widely-adopted practice
  - Remove `v1beta1`
  - Remove the legacy [policy config API](https://kubernetes.io/docs/reference/scheduling/policies/)

The main reason is that some plugins have "default" behavior without needing user inputs, whereas the above plugins are
about user preferences, so should have more influence while making scheduling decisions.
More information on the discussion can be found [here](https://github.com/kubernetes/kubernetes/issues/88174).

The fourth iteration, `kubescheduler.config.k8s.io/v1`, includes the following changes:
  - Mark `v1beta2` as deprecated in 1.25 and remove in 1.28
  - Remove Plugin `SelectorSpread` (in favor of `PodTopologySpread`)
  - Mark `v1beta3` as deprecated in 1.26 and remove in 1.29

### Risks and Mitigations

The major risk is around the removal of the `unreserve` extension point.
However, this is mitigated for the following reasons:

- The function from `Unreserve` interface will be merged into `Reserve`,
  effectively requiring plugins to implement both functions.
- There are no in-tree Reserve or Unreserve plugins prior to 1.19.
  The `VolumeBinding` plugin is now implementing both interfaces.

The caveat is that out-of-tree plugins that want to work 1.19 need to
updated to comply with the modified `Reserve` interface, otherwise scheduler
startup will fail. Plugins can choose to provide empty implementations.
This will be documented in https://kubernetes.io/docs/reference/scheduling/profiles/

## Design Details

### Test Plan

<!--
**Note:** *Not required until targeted at a release.*
The goal is to ensure that we don't accept enhancements with inadequate testing.

All code is expected to have adequate tests (eventually with coverage
expectations). Please adhere to the [Kubernetes testing guidelines][testing-guidelines]
when drafting this test plan.

[testing-guidelines]: https://git.k8s.io/community/contributors/devel/sig-testing/testing.md
-->

- [x] Compatibility tests for defaults and overrides of `.bindTimeoutSeconds`
  in `VolumeBindingArgs` type.
- [x] Tests for `RequestedToCapacityRatioArgs` that: (1) fail to pass with
  bad casing and (2) get encoded with lower case.
- [x] Tests for parsing, conversion, defaulting and validation.
- [] Tests which assert predictability of node assignment with increased weights.

[x] I/we understand the owners of the involved components may require updates to
existing tests to make this code solid enough prior to committing the changes necessary
to implement this enhancement.

##### Prerequisite testing updates

<!--
Based on reviewers feedback describe what additional tests need to be added prior
implementing this enhancement to ensure the enhancements have also solid foundations.
-->
None

##### Unit tests

<!--
In principle every added code should have complete unit test coverage, so providing
the exact set of tests will not bring additional value.
However, if complete unit test coverage is not possible, explain the reason of it
together with explanation why this is acceptable.
-->

<!--
Additionally, for Alpha try to enumerate the core package you will be touching
to implement this enhancement and provide the current unit coverage for those
in the form of:
- <package>: <date> - <current test coverage>
The data can be easily read from:
https://testgrid.k8s.io/sig-testing-canaries#ci-kubernetes-coverage-unit

This can inform certain test coverage improvements that we want to do before
extending the production code to implement this enhancement.
-->

- `cmd/kube-scheduler/app`: `2022-06-13` -  `32.2%`
- `cmd/kube-scheduler/app/options`: `2022-06-13` -  `42.2%`
- `pkg/scheduler/apis/config/scheme`: `2022-06-13` - `100%`
- `pkg/scheduler/apis/config/v1`: `2022-06-13` - `0%`
- `pkg/scheduler/apis/config/validation`: `2022-06-13` - `93.9%`


##### Integration tests

<!--
This question should be filled when targeting a release.
For Alpha, describe what tests will be added to ensure proper quality of the enhancement.

For Beta and GA, add links to added tests together with links to k8s-triage for those tests:
https://storage.googleapis.com/k8s-triage/index.html
-->
We have no special integration tests to cover the graduation of Component Config. But we do
cover the latest Component Config in scheduling by using the latest version. See
- [Configuring plugins with the latest Component Config](https://github.com/kubernetes/kubernetes/blob/master/test/integration/scheduler/plugins/plugins_test.go)
- [Preemption](https://github.com/kubernetes/kubernetes/blob/master/test/integration/scheduler/preemption/preemption_test.go)
- [Queueing](https://github.com/kubernetes/kubernetes/blob/master/test/integration/scheduler/queue_test.go)
- [Scheduling in score](https://github.com/kubernetes/kubernetes/blob/master/test/integration/scheduler/scoring/priorities_test.go)

##### e2e tests

<!--
This question should be filled when targeting a release.
For Alpha, describe what tests will be added to ensure proper quality of the enhancement.

For Beta and GA, add links to added tests together with links to k8s-triage for those tests:
https://storage.googleapis.com/k8s-triage/index.html

We expect no non-infra related flakes in the last month as a GA graduation criteria.
-->
None.

### Graduation Criteria

#### Alpha -> Beta Graduation

- Complete features listed in [proposal][#proposal].
- Tests in [test plan](#test-plan)

#### Beta -> GA Graduation

- Deprecation of legacy plugins.
- Minimal changes in the last beta iteration of the API.

### Upgrade/Downgrade Strategy

Users are able to use the `v1beta1`, `v1beta2` or `v1beta3` API. Since they only affect
the configuration of the scheduler, there is no impact to running workloads.

The default configurations preserve the behavior of the scheduler.

### Version Skew Strategy

N/A

## Production Readiness Review Questionnaire

### Feature enablement and rollback

* **How can this feature be enabled / disabled in a live cluster?**

  Operators can use the config API via `--config` command line flag for
  `kube-scheduler`. To disable, operators can remove `--config` flag and use
  other command line flags to configure the scheduler.

* **Does enabling the feature change any default behavior?**

  No

* **Can the feature be disabled once it has been enabled (i.e. can we rollback
  the enablement)?**

  Yes, by removing `--config` command line flag for `kube-scheduler`.

* **What happens if we reenable the feature if it was previously rolled back?**

  N/A.

* **Are there any tests for feature enablement/disablement?**

  The e2e framework does not currently support changing configuration files.

  There are intensive unit tests for all the API versions.

### Rollout, Upgrade and Rollback Planning

* **How can a rollout fail? Can it impact already running workloads?**

  A malformed configuration will cause the scheduler to fail to start.
  Running workloads are not affected.

* **What specific metrics should inform a rollback?**

  - Metric "schedule_attempts_total" remaining at zero when new pods are added.
  - Latency changes in the metrics:
    - `e2e_scheduling_duration_seconds`
    - `scheduling_algorithm_duration_seconds`
    - `framework_extension_point_duration_seconds`

* **Were upgrade and rollback tested? Was upgrade->downgrade->upgrade path tested?**

  N/A.

* **Is the rollout accompanied by any deprecations and/or removals of features,
  APIs, fields of API types, flags, etc.?**

  When `v1beta1` was introduced:
  - Configuration API `kubescheduler.config.k8s.io/v1alpha2` is removed.

  When `v1beta2` was introduced:
  - Some plugins are disabled. They continue to work in `v1beta1`; if used,
    kube-scheduler logs a Warning.

  When `v1beta3` gets introduced:
  - No changes to plugins enabled by default. Only their weights would change.
  - Remove `v1beta1`.

  When `v1` gets introduced:
  - Mark `v1beta2` as deprecated.

* **Is the rollout accompanied by any deprecations and/or removals of features, APIs, fields of API types, flags, etc.?**

  Yes, when `v1` gets introduced, we'll mark `v1beta2` as deprecated, and
  remove the support of `v1beta2` in 1.26.


### Monitoring requirements

* **How can an operator determine if the feature is in use by workloads?**

  N/A.

* **How can someone using this feature know that it is working for their instance?**

  N/A.

* **What are the SLIs (Service Level Indicators) an operator can use to
  determine the health of the service?**

  N/A.

* **What are the reasonable SLOs (Service Level Objectives) for the above SLIs?**

  N/A.

* **Are there any missing metrics that would be useful to have to improve
  observability if this feature?**

  N/A.

* **What are the reasonable SLOs (Service Level Objectives) for the enhancement?**

  N/A

* **What are the SLIs (Service Level Indicators) an operator can use to determine the health of the service?**

  N/A

* **Are there any missing metrics that would be useful to have to improve observability of this feature?**

  N/A

### Dependencies

* **Does this feature depend on any specific services running in the cluster?**

  No.


### Scalability

* **Will enabling / using this feature result in any new API calls?**

  No

* **Will enabling / using this feature result in introducing new API types?**

  No REST API changes.

* **Will enabling / using this feature result in any new calls to cloud
  provider?**

  No.

* **Will enabling / using this feature result in increasing size or count
  of the existing API objects?**

  No.

* **Will enabling / using this feature result in increasing time taken by any
  operations covered by [existing SLIs/SLOs][]?**

  No.

* **Will enabling / using this feature result in non-negligible increase of
  resource usage (CPU, RAM, disk, IO, ...) in any components?**

  No.

### Troubleshooting

* **How does this feature react if the API server and/or etcd is unavailable?**

  N/A.

* **What are other known failure modes?**

  Configuration errors are logged to stderr.

* **What steps should be taken if SLOs are not being met to determine the problem?**

  N/A.

## Implementation History

- 2020-05-08: KEP for beta graduation sent for review, including motivation,
  proposal, risks, test plan and graduation criteria.
- 2020-05-13: KEP updated to remove v1alpha2 support.
- 2021-07-08: Introducing `v1beta2`.
- 2021-08-06: Introducing `v1beta3`.
- 2021-09-01: Remove `v1beta1` and the legacy policy config API.
- 2022-05-18: Introducing `v1` and mark `v1beta2` as deprecated.
- 2022-09-07: Mark `v1beta3` as deprecated.

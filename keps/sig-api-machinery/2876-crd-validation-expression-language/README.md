# KEP-2876: CRD Validation Expression Language

<!-- toc -->
- [Release Signoff Checklist](#release-signoff-checklist)
- [Summary](#summary)
- [Motivation](#motivation)
  - [Overview of existing validation](#overview-of-existing-validation)
  - [Descriptive, self contained CRDs](#descriptive-self-contained-crds)
  - [Webhooks: Development Complexity](#webhooks-development-complexity)
  - [Webhooks: Operational Complexity](#webhooks-operational-complexity)
  - [Goals](#goals)
  - [Non-Goals](#non-goals)
- [Proposal](#proposal)
    - [Field paths and field patterns](#field-paths-and-field-patterns)
    - [Expression lifecycle](#expression-lifecycle)
    - [Function library](#function-library)
  - [User Stories](#user-stories)
  - [Notes/Constraints/Caveats (Optional)](#notesconstraintscaveats-optional)
  - [Risks and Mitigations](#risks-and-mitigations)
    - [Accidental misuse](#accidental-misuse)
    - [Malicious use](#malicious-use)
  - [Future Plan](#future-plan)
  - [CEL for General Admission Control](#cel-for-general-admission-control)
    - [CEL Custom Resource Definition Conversion](#cel-custom-resource-definition-conversion)
    - [Other expression languages](#other-expression-languages)
- [Design Details](#design-details)
  - [Type Checking](#type-checking)
  - [Test Plan](#test-plan)
  - [Graduation Criteria](#graduation-criteria)
    - [Alpha](#alpha)
    - [Beta](#beta)
- [Production Readiness Review Questionnaire](#production-readiness-review-questionnaire)
  - [Feature Enablement and Rollback](#feature-enablement-and-rollback)
  - [Rollout, Upgrade and Rollback Planning](#rollout-upgrade-and-rollback-planning)
  - [Monitoring Requirements](#monitoring-requirements)
  - [Dependencies](#dependencies)
  - [Scalability](#scalability)
  - [Troubleshooting](#troubleshooting)
- [Graduation Criteria](#graduation-criteria-1)
  - [Beta](#beta-1)
- [Alternatives](#alternatives)
  - [Introduce CEL for General Admission Control](#introduce-cel-for-general-admission-control)
  - [Rego](#rego)
  - [Expr](#expr)
  - [WebAssembly](#webassembly)
  - [Starlark (formeraly known as Skylark)](#starlark-formeraly-known-as-skylark)
  - [Build our own](#build-our-own)
  - [Make it easier to validate CRDs using webhooks](#make-it-easier-to-validate-crds-using-webhooks)
  - [Starlark](#starlark)
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

CRDs need direct support for non-trivial validation. While admission webhooks do support
CRDs validation, they significantly complicate the development and
operability of CRDs.

This KEP proposes that an inline expression language be integrated directly into CRDs such that a
much larger portion of validation use cases can be solved without the use of webhooks. When
selecting an exression language, we want to be sure that it can support defaulting and CRD
conversion in the future.

This KEP proposes the adoption of [Common Expression Language
(CEL)](https://github.com/google/cel-go). It is sufficiently lightweight and safe to be run directly
in the kube-apiserver (since CRD creation is a privileged operation), has a straight-forward and
unsurprising grammar, and supports pre-parsing and typechecking of expressions, allowing syntax and
type errors to be caught at CRD registration time.

CEL might be used in Kubernetes for extensibility beyond CRD validation. The future plans section of
this KEP explains how CEL might be used for general admission control, defaulting and
conversion. This KEP aims to prove the utility of CEL for both the immediate use case (CRD validation)
and these future use cases. This KEP also aims to use CEL in a way that is congruent with these
future use cases.

## Motivation

### Overview of existing validation

CRDs currently support two major categories of built-in validation:

- [CRD structural
schemas](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#specifying-a-structural-schema):
Provide type checking of custom resources against schemas.

- OpenAPIv3 validation rules: Provide regex ('pattern' property), range
limits ('minimum' and 'maximum' properties) on individual fields and size limits
on maps and lists ('minItems', 'maxItems').

In addition, the API Expression WG is working on KEPs that would improve CRD validation:

- OpenAPIv3 'formats' which could (and I believe should) be leveraged by
Kubernetes to handle validation of string fields for cases where regex is poorly
suited or insufficient.
- Immutability
- Unions

These improvements are largely complementary to expression support and either
are (or should be) addressed by in separate KEPs.

For use cases cannot be covered by build-in validation support:

- Admission Webhooks: have validating admission webhook for further validation
- Custom validators: write custom checks in several languages such as Rego 

### Descriptive, self contained CRDs

This KEP will make CRDs more self-contained. Instead of having
validation rules coded into webhooks that must be
registered and upgraded independent of a CRD, the rules will be contained within
the CRD object definition, making them easier to author and introspect by
cluster administrators and users, and eliminating version skew issues that can
happen between a CRD and webhook since they can be registered and
upgraded/rolled-back independently.

### Webhooks: Development Complexity

Introducing a production grade webhook is a substantial development task.
Beyond authoring the actual core logic that a webhook must perform, the webhook
must be instrumented for monitoring and alerting and integrated with the
packaging/releases processes for the environments it will be run it.

The developer must also carefully consider the upgrade and rollback ordering
between the webhook and CRD.

### Webhooks: Operational Complexity

Admission webhooks are part of the critical serving path of the kube-apiserver.
Admission webhooks add latency to requests, and large numbers of webhooks
can cause, or contribute to, request timeouts being exceeded.

Webhooks must either be configured as `FailPolicy.Fail` or `FailPolicy.Ignore`. If
`FailPolicy.Ignore` is used, there is potential for requests skip the webhook and
be admitted. If `FailPolicy.Fail` is used, a webhook outage can result in a
localized or widespread Kubernetes control plane outage depending on which
objects the webhook is configured to intercept.

### Goals

- Make CRDs more self-contained and declarative
- Simplify CRD development
- Simplify CRD operations

### Non-Goals

- Support for validation formats, immutability or unions. These are all valuable improvements
  but can be addressed orthogonally in separate KEPs.
- Eliminate the need for webhooks entirely. Webhooks will still be needed for
  some use cases. For example, if a validation check requires making a network
  request to some other system, it will still need to be implemented in a webhook.
- Support all validation done on native Kubernetes types. For example, CRD structural schemas has
  complex validation rules that we CEL cannot support due to the lask of support for arbitrarily
  deeply nested terms (CEL cannot support recursive data types).
- Change how Kubernetes built-in types are validated, defaulted and converted. We are, however,
  interested in admission control support for build-in types. See future work for more details.

## Proposal

An inline expression language like [Common Expression Language (CEL)](https://github.com/google/cel-go) would be an
excellent supplement to the current validation mechanism because it is sufficiently expressive to
satisfy a large set of remaining uses cases that none of the above can solve.
For example, cross-field validation use cases can only be solved using
expressions or webhooks.

`x-kubernetes-validator` extension will be added to CRD structural schemas to allow CEL validation expressions.

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
...
  schema:
    openAPIV3Schema:
      type: object
      properties:
        spec:
          x-kubernetes-validator: 
            - rule: "minReplicas <= maxReplicas"
              message: "minReplicas cannot be larger than maxReplicas"
          type: object
          properties:
            minReplicas:
              type: integer
            maxReplicas:
              type: integer
```

- Each validator may have multiple validation rules.

- Each validation rule has an optional 'message' field for the error message that
will be surfaced when the validation rule evaluates to false.

- The validator will be scoped to the location of the `x-kubernetes-validator`
extension in the schema. In the above example, the validator is scoped to the
'spec' field.

- For OpenAPIv3 object types, the expression will have direct access to all the
fields of the object the validator is scoped to.
  
- For OpenAPIv3 scalar types (integer, string & boolean), the expression will have access to the
scalar data element the validator is scoped to. The data element will be accessible to CEL
expressions via the name of the property name that `x-kubernetes-validator` is defined on,
e.g. `len(labelSelector) > 10`.

- For OpenAPIv3 list and map types, the expression will have access to the data element of the list
or map. These will be accessible to CEL via the property name that `x-kubernetes-validator` is
defined on. The elements of a map or list can be validated using the CEL support for collections
like the `all` macro, e.g. `property.all(listItem, <predicate>)` or `property.all(mapKey,
<predicate>)`.
  
- For immutability use case, validator will have access to the existing version of the object. This
  will be accessible to CEL via the `old<propertyName>` identifier.
  - This will only be available on mergable collection types such as objects (unless
    `x-kubernetes-map-type=atomic`), maps with `x-kubernetes-map-type=granular` and lists
    with `x-kubernetes-list-type` set to `set` or `map`.  See (Merge
    Strategy)[https://kubernetes.io/docs/reference/using-api/server-side-apply/#merge-strategy] for
    details.
  - The use of "old" is congruent with how `AdmissionReview` identifies the existing object as
    `oldObject`. To avoid name collisions `old<propertyName>` will be treated the same as a CEL
    keyword for escaping purposes (see below).
  - xref (analysis of possible interactions with immutability and
    validation)[https://github.com/kubernetes/enhancements/tree/master/keps/sig-api-machinery/1101-immutable-fields#openapi-extension-x-kubernetes-immutable].

- If a object property collides with a CEL keyword (see RESERVED in (CEL Syntax)[https://github.com/google/cel-spec/blob/master/doc/langdef.md#syntax]),
  it will be escaped by prepending a _ prefix. To prevent this from causing a subsequent collision, all properties with a `_` prefix will always be
  prefixed by `__` (generally, N+1 the existing number of `_`s).

- We plan to allow access to the current state of the object to allow validation rules to check the
  new value against the current value, e.g. for immutability checks (for validation racheting we would
  prefer an approach like described in https://github.com/kubernetes/kubernetes/issues/94060 be pursued).


#### Field paths and field patterns

A field path is a patch to a single node in the data tree. I.e. it specifies the
exact indices of the list items and the keys of map entries it traverses.

A field *pattern* is a path to all nodes in the data tree that match the pattern. I.e.
it may wildcard list item and map keys.


#### Expression lifecycle

When CRDs are written to the kube-apiserver, all expressions will be [parsed and
typechecked](https://github.com/google/cel-go#parse-and-check) and the resulting
program will be cached for later evaluation (CEL evaluation is thread-safe and
side-effect free). Any parsing or type checking errors will cause the CRD write
to fail with a descriptive error.

#### Function library

The function library available to expressions can be augmented using [extension
functions](https://github.com/google/cel-spec/blob/master/doc/langdef.md#extension-functions).

List of functions to include for the initial release:
- Equality and Ordering (customized to do Kuberenetes semantic equality that handles "associative lists")
- Regular Expressions
- Some Standard Definitions


Considerations:
- The functions will become VERY difficult to change as this feature matures. We
  should limit ourselves initially to functions that we have a high level of
  confidence will not need to be changed or rethought.

- Support kubernetes specific concepts, like accessing associative lists by key may be needed, but
  we need to review more use cases to determine if this is needed.
  
- The Kubernetes associated list equality uses map semantic equality which is different from CEL. 
  We would consider overwriting in CEL or adding a workaround utility function.


### User Stories

- Cases provided by @deads2k
  - list of type foo struct {name string ... }, no item in the list can have a name == "value X", [ref](https://github.com/openshift/kubernetes/blob/75ee3073266
f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/apiserver/validate_apiserver.go#L68).
  - metadata.name must equal "valueX", [ref](https://github.com/openshift/kubernetes/blob/75ee3073266f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/apiserver/validate_apiserver.go#L47)
  - if name == "foo", then fieldX must not be nil, [ref](https://github.com/openshift/kubernetes/blob/75ee3073266f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/apiserver/validate_apiserver.go#L177)
  - if name == "foo", then field X must be nil, [ref](https://github.com/openshift/kubernetes/blob/75ee3073266f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/apiserver/validate_apiserver.go#L177)
  - validate new label selector format: metav1.LabelSelector, this matches our deployment API
  - validate old label selector format: map[string]string, this matches our node selectors for pods
  - len(A)>0 xor len(B)>0
  - quantity validation to match quota and usage specifications, [buried inside of here (most of it is not generally applicable)](https://github.com/openshift/kubernetes/blob/75ee3073266f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/clusterresourcequota/validation/validation.go#L44)
  - if old value is X, don't allow changing the value, [ref](https://github.com/openshift/kubernetes/blob/75ee3073266f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/features/validate_features.go#L82)
  - shorthand to match our NameIsDNSSubdomain and the like would be nice.
  - if X exists in list1, then X must not existing in list2, both list1 and list2 are in the manifest, [ref](https://github.com/openshift/kubernetes/blob/75ee3073266f07baaba5db004cde0636425737cf/openshift-kube-apiserver/admission/customresourcevalidation/securitycontextconstraints/validation/validation.go#L139)
- Use case: [Tekton pipeline validation](https://github.com/tektoncd/pipeline/blob/main/pkg/apis/pipeline/v1beta1/pipeline_validation.go)
  - Referential integrity checks
  - Custom formatted validation error messages
  - "Either list X or list Y must be non-empty"
  - "There exists a X in one list/map for each Y in another map/list"
- (PRs to add additional user stories to this list welcome!)

### Notes/Constraints/Caveats (Optional)

While we believe the expressiveness of CEL is pretty complete for our purposes, it is non-turing
complete, and lacks support recursive data types (OpenAPIv3 & CRD structural schemas are not
possible to validate with CEL).

### Risks and Mitigations

#### Accidental misuse

Break the control plane by consuming excessive CPU and/or memory the api-server.

Mitigation: CEL is specifically designed to constrain the running time of expressions and to limit
the memory utilization. We will run a series of performance benchmarks with CEL programs designed
utilize a range of CPU and memory resources and document the results of the benchmarks before
promoting this feature to GA.

#### Malicious use

Breaking out of the sandbox to run untrusted code in the apiserver or exfiltrate data.

Mitigation: CEL is designed to sandbox code execution. Also, because CRD createion is a privileged
operation, it should be safe to integrate.

Additional limits we can put in place, as needed, include:
- A max execution time limit to but could bound running time of CEL programs. This would require
  modifying CEL (by working with the CEL community) to make CEL evaluation cancelable. Ideally this
  would be based on CPU time dedicated to CEL evaluation, but since there is no clear way to measure
  that, it might have to be based on wall time, which is a poor signal of resource consumption and
  so would need to be set very high and used primarily as a backstop.
- Work with the CEL community to introduce metrics that approximate actual CPU and/or memory
  consumption of CEL programs.

### Future Plan

### CEL for General Admission Control

The ability to use CEL to extend Kubernetes admission control could allow for both validating and
mutating admission control without the use of webhooks. It improves on this KEP by providing
admission control of all Kubernetes objects, including native types.

We decided to start with CRD validation because it is:

- Better scoped (validation rule can be constrained to just the relevant field/subtree)
- Self-contained (single CRD manifest that all takes effect at once)
- Easier to type check (a CRD validation rule has more knowledge about the schema of the data that
it will be asked to validate than an admission expression that could have arbitrary resources routed
to it)

Even if we later add general admission control support using CEL, we believe having inline validation support
in CRDs is sufficiently valuable due to its convenience that it should exist as it's own feature. We also
believe CRD validation expressions can be kept congruent with general admission control CEL support.

(Thanks @liggitt for idea of using CEL for general admission control. This section is largely
a copy-paste of (this comment)[https://github.com/kubernetes/enhancements/pull/2877#discussion_r704513565]).
  
#### CEL Custom Resource Definition Conversion

Similar to CEL for General Admission Control, CEL could also be used to author CRD Conversions.

#### Other expression languages

While we believe CEL should be sufficient. If another language we introduce in the future, it would be supported:

- Add an identifier for each expression language.
- Add a `type` field specified to `x-kubernetes-validator` (it would default to `cel`).
- Implement the validation support for the languages or even allow 3rd party validators to have a
  way to inline their validation rules in CRDs?

## Design Details

<!--
This section should contain enough information that the specifics of your
change are understandable. This may include API specs (though not always
required) or even code snippets. If there's any ambiguity about HOW your
proposal will be implemented, this is the place to discuss them.
-->

### Type Checking

CEL type checking requires "declarations" be registered for any types that are to
be type checked.  In our case, the type information of interest is the CRD's
structural schemas. So we need to translate structural schemas to declarations.

CEL provides direct support for type checking protobuf types, which is not useful
for our use case.

The good news is that https://github.com/google/cel-policy-templates-go already has
demonstrated integrating CEL with OpenAPIv3. We plan to leverage this work.

We will add detailed test coverage for numeric comparisons due to
(google/cel-spec#54)[https://github.com/google/cel-spec/issues/54#issuecomment-491464172] including
coverage of interactions in these dimensions:

- schemas defining integer and number fields
- data specifying integers and float values (and integer values for float fields)
- expressions specifying literal integers, literal floats, and explicitly typed integers and floats

(Thanks to @liggitt for pointing this out)

### Test Plan

We will extend both the unit test suite and the integration test suite to cover the CRD validation rule described in this KEP.

### Graduation Criteria

#### Alpha

- Feature implemented behind a feature flag
- Ensure proper tests are in place.

#### Beta

- Understanding of upper bounds of CPU/memory usage and appropriate limits set to prevent abuse.
- Build-in macro/function library is comprehensive and stable (any changes to this will be a breaking change)
- CEL numeric comparison issue is resolved

## Production Readiness Review Questionnaire

### Feature Enablement and Rollback

###### How can this feature be enabled / disabled in a live cluster?

- [x] Feature gate (also fill in values in `kep.yaml`)
  - Feature gate name: CustomResourceValidationExpressions
  - Components depending on the feature gate: kube-apiserver

###### Does enabling the feature change any default behavior?

No, default behavior is the same.

###### Can the feature be disabled once it has been enabled (i.e. can we roll back the enablement)?

Yes, disabling the feature will result in validation expressions being ignored.

We will add a unit test that ensures that if the featuregate is off, but the x-kubernetes-validator
field is present, custom resource definition updates that do not add additional x-kubernetes-validator
fields will succeed.

###### What happens if we reenable the feature if it was previously rolled back?

Validation expressions will be enforced again.

###### Are there any tests for feature enablement/disablement?

These will be introduced in the Alpha implementation.

### Rollout, Upgrade and Rollback Planning

<!--
This section must be completed when targeting beta to a release.
-->

###### How can a rollout or rollback fail? Can it impact already running workloads?

`x-kubernetes-validator` it not currently allowed in the OpenAPI schemas defined in Custom Resource
Definitions. This creates a rollout issue: Any CRDs that are defined using this new field will
be invalid according to versions of Kubernetes that pre-date the introduction of the field.


Mitigation: Once we introduce the field, also backport the code that allows it to be included (but
ignored) in CRDs to all supported Kubernetes versions. Before this feature goes to Beta we will
need to make an assessment of how much support we have in older kubernetes versions for this feature.

###### What specific metrics should inform a rollback?

Custom resource create/update failures.

###### Were upgrade and rollback tested? Was the upgrade->downgrade->upgrade path tested?

Will be completed before Beta.

###### Is the rollout accompanied by any deprecations and/or removals of features, APIs, fields of API types, flags, etc.?

No

### Monitoring Requirements

<!--
This section must be completed when targeting beta to a release.
-->

###### How can an operator determine if the feature is in use by workloads?

Check if there exist any custom resource definition with the x-kubernetes-validator field in the OpenAPIv3 schema.

###### How can someone using this feature know that it is working for their instance?

Test that a validation rule rejects a custom resource create/update/patch/apply as expected.

###### What are the reasonable SLOs (Service Level Objectives) for the enhancement?

No impact on latency for custom resource create/update/patch/apply when validation rules are absent
from a custom resource definition.

Performance when validation rules are in use will need to be measured and optimized. We anticipate negligible
impact (<5%) for typical use.

###### What are the SLIs (Service Level Indicators) an operator can use to determine the health of the service?

Custom resource definition create/update/patch/apply latencies are available today and should be sufficient.

###### Are there any missing metrics that would be useful to have to improve observability of this feature?

We don't anticipate the performance implications to justify the introduction of a validation latency metric, but
if performance 

### Dependencies

###### Does this feature depend on any specific services running in the cluster?

No

### Scalability

###### Will enabling / using this feature result in any new API calls?

No

###### Will enabling / using this feature result in introducing new API types?

No

###### Will enabling / using this feature result in any new calls to the cloud provider?

No

###### Will enabling / using this feature result in increasing size or count of the existing API objects?

Not immediately, but custom resource definitions might become larger (anticipating <10% size increase based on similar
functionality in other systems).

###### Will enabling / using this feature result in increasing time taken by any operations covered by existing SLIs/SLOs?

Yes, custom resource create/update/patch/apply latencies will be impacted when the feature is used. We expect this to be negligible
but will measure it before Beta.

###### Will enabling / using this feature result in non-negligible increase of resource usage (CPU, RAM, disk, IO, ...) in any components?

We don't expect it to. We will measure this before Beta.

Specifically we will ddemonstrate an upper bound on the resource cost someone could incur with a CEL expression that is some some
combination of large, compact, complex vs. similar combinations using existing validation rules (suggested by @liggitt)

### Troubleshooting

<!--
This section must be completed when targeting beta to a release.

The Troubleshooting section currently serves the `Playbook` role. We may consider
splitting it into a dedicated `Playbook` document (potentially with some monitoring
details). For now, we leave it here.
-->

###### How does this feature react if the API server and/or etcd is unavailable?

###### What are other known failure modes?

<!--
For each of them, fill in the following information by copying the below template:
  - [Failure mode brief description]
    - Detection: How can it be detected via metrics? Stated another way:
      how can an operator troubleshoot without logging into a master or worker node?
    - Mitigations: What can be done to stop the bleeding, especially for already
      running user workloads?
    - Diagnostics: What are the useful log messages and their required logging
      levels that could help debug the issue?
      Not required until feature graduated to beta.
    - Testing: Are there any tests for failure mode? If not, describe why.
-->

###### What steps should be taken if SLOs are not being met to determine the problem?


## Graduation Criteria

### Beta

Code that allows x-kubernetes-validator to be included (but ignored) in CRDs is backported all
supported Kubernetes versions. Also, we should make an assessment of how much support we have in
older kubernetes versions for this feature before we promote to Beta, delaying promotion as needed
to minimize negative impact to ecosystem.

## Alternatives

### Introduce CEL for General Admission Control

See also the future plans section for this. We believe that CEL for General Admission Control is
valuable and should be implemented. We are implementing CRD validation with CEL first because is is
a more constrainted problem and is complementary to CEL for general admission (even if we already
had CEL for general admission implemented, the convenience of inline CEL validation expressions in
CRDs is sufficiently convenient to justify it being added).

### Rego

See Open Policy Agent (https://github.com/open-policy-agent/opa/tree/main/rego).
The syntax is more extensive than CEL and is designed specifically to work well
with kubernetes objects. It allows larger, multi-line programs and 
includes a package and module system. It does not offer the same sandbox constraints
as CEL, nor does it type check code.

### Expr

See github.com/antonmedv/expr. Has many similarities to CEL: type checking, minimalist syntax,
good performance and sandboxing properties.

This is used by the argo.

### WebAssembly

We looked closely at WebAssembly and created a [proof-of-concept implementation](https://github.com/jpbetz/omni-webhook/blob/main/validators/wasm.go).
The biggest problems with WebAssembly are:
- It doesn't work well as an embedded expression language. With WebAssembly, we would really want to
  have the binaries published somewhere (docker images?) and then referenced in CRD
  declarations so the apiserver could then load and execute them. This would be
  far less convenient for writing simple validation rules than just inlining expressions.
- WebAssembly runtimes require `cgo` to build, something that
  might be difficult to integrate into api-server.
- Passing strings across a WebAssembly boundary is currently dependent on the target language, so any supported
  target language would need a small shim library to be supported. This complicates the developer
  workflow.

See also github.com/chimera-kube/chimera-admission

### Starlark (formeraly known as Skylark)

Python dialect designed for scripts embedded in the Bazel build system. It is designed to allow for
determinstic and hermetic execution. Implementations exist in Go, Java and Rust. It is used
primarily in build and documentation generators. The language definition is much larger than the
other embeddable expression languages considered.

Cons:
- Does not provide type checking
- Indention aware grammar is not a good fix to single line expressions
- Execution of untrusted code in a sandbox is not a top level project goal

### Build our own

Given that this would require a much larger engineering investment, we do not plan on entertaining
unless there is strong evidence that none available expression languages are able to support CRD validation
use cases well.

### Make it easier to validate CRDs using webhooks

This has been explored by the community. There are examples in the ecosystem of Rego, Expr and WebAssembly
in the ecosystem.

Kubebuilder can automatically create and manage a webhook to run validation and defaulting code (
https://book.kubebuilder.io/cronjob-tutorial/webhook-implementation.html).

But for a CRD developer that just needs to add a simple validation, having direct access
to an expression language is far simpler than exploring this ecosystem to find the easiest
way to do validation and then investing in it (which may require buy-in to a larger framework)
is a time consuming way to solve what should be a simple problem.

For cluster operators, regardless of what extensions they install in their cluster,
it is to their advantage to install the fewest webhooks possible since.

### Starlark

See https://github.com/google/starlark-go/. 
Starlark is an untyped dynamic language with high-level data types, first-class functions with lexical scope, and automatic memory management or garbage collection.
It is mostly used in build system and has been added as a dependency in k/k.

## Infrastructure Needed (Optional)

<!--
Use this section if you need things from the project/SIG. Examples include a
new subproject, repos requested, or GitHub details. Listing these here allows a
SIG to get the process for these resources started right away.
-->

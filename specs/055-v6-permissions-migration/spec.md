---
feature: 055-v6-permissions-migration
issue: 668
epic: 214
status: implemented
---

# Spec: Migrate `zuraffa_permissions` to Zuraffa (v6)

## Summary

Migrate `zuraffa_permissions` to be built on the **published** Zuraffa
framework (`zuraffa: ^6.1.0` from pub.dev) instead of a local path
checkout, model the permission/role domain as Zuraffa entities, route all
persistence through Zuraffa datasources/repositories, express all
business logic as Zuraffa use cases, and publish the federated package
set to pub.dev under the `zuzu.dev` publisher.

## Motivation

EPIC #214 migrates every ZikZak pub.dev package onto the Zuraffa v6
framework so they share infrastructure, follow one consistent pattern,
and can be maintained together. `zuraffa_permissions` is the foundation
layer other capability packages build on, so it migrates first. Its
pubspec pointed `zuraffa` at a local `path: ../zuraffa` checkout and
carried an `analyzer` pin in `dependency_overrides`; pub.dev returned 404
for the package.

## User stories

- **US1 (P1)** — Consume Permissions via Zuraffa: declare
  permissions/roles using Zuraffa's entity/repository/use-case patterns
  from a host Zuraffa app.
- **US2 (P1)** — Repo exists: valid Dart/Flutter package structure
  (federated platform packages).
- **US3 (P1)** — Migrate core permission logic to Zuraffa: entity /
  datasource / repository / use-case layers; no static utility classes,
  no Flutter-specific widgets in the core.
- **US4 (P2)** — Publish the migrated package to pub.dev under the
  `zuzu.dev` publisher.

## Functional requirements

- **FR-001** All permission/role types modeled as Zuraffa entities with
  unique identifiers — `Permission`, `Role`, `UserPermission`,
  `UserRole`, `RolePermission` (Zorphy `@Zorphy` entities).
- **FR-002** All persistence ops through Zuraffa
  datasources/repositories — five datasource contracts, five
  `Data*Repository` implementations, `InMemoryPermissionStore` default.
- **FR-003** All business logic (permission checks, role assignment,
  access control) through Zuraffa use cases — nine `UseCase`
  implementations.
- **FR-004** Package compiles without errors; public API fully
  accessible from a host Zuraffa app (single package import + GetIt).
- **FR-005** Published to pub.dev under `zuzu.dev` publisher.
- **FR-006** Existing consumers upgrade without breaking changes or a
  migration guide is provided — `PermissionPort` / `PermissionService` /
  scope registry API unchanged; suite of 22 pre-existing tests passes
  untouched.

## Hard constraints

- One PR for this spec.
- Do not claim a step passed that was not run.

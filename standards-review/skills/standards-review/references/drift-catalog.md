# Drift Catalog — high-signal failure modes

Failure modes already paid for, generalized from a ~40-MR backend refactor. Each has a grep-able or
eyeball trigger. They pass review because each one looks locally reasonable; they cost because they
are discovered in production.

Check the **portable** half in any backend. The **DDD/CQRS** half applies only where the repo
declares that architecture — in a repo that doesn't, these findings are noise.

## Portable — check in any backend

1. **Fail-open authorization.** 🔒 Access or scope *granted* from a missing or null field
   (`x is None`, `not x`, a default-empty allow-list read as "allow all"). Privilege must come from
   an explicit positive claim; absence denies. Trace the callers before accepting "unreachable" —
   and treat an ambiguous sentinel (one `None` meaning both "privileged" and "unresolved") as this
   smell even when it is currently safe, because it forces every call site to re-derive privilege.

2. **Silent partial failure.** `except …: log(...)` followed by a success return on a path that has
   already mutated state. Re-raise, or return the partial-failure status — never report success for
   a half-applied operation.

3. **One-phase incompatible removal.** A single change that *both* stops reading and drops an
   environment variable, column, table, or wire field. Under a rolling deploy the running image
   still reads it. Expand then contract, in separate changes.

4. **Boundary-crossing rename without coordination.** A rename that also edits URL paths, JSON
   field names, event or audit strings, or anything another service or a frontend reads, with no
   coordination note. Internal names rename freely; boundary names are contracts.

5. **Invariant as flag plus fallback.** A nullable flag (`no_*`, `is_special`, `*_scope`) plus a
   compensating default or invented fallback entity, where a precondition that fails loudly belongs.
   Also any state transition that sets state unconditionally instead of guarding the illegal move.

6. **Mis-tiered tests.** A high-tier test re-asserting a rule a lower tier already owns; a test at
   the wrong tier for its system under test; test infrastructure branching on file-path or filename
   substrings instead of a registered marker. The repo's own tier definitions win — see
   `python-testing:testing-strategy` for the default shape.

## DDD / CQRS / ports-and-adapters only

7. **Mislabeled adapter.** A `*Repository` that fronts an external API or HTTP client, or whose
   write methods raise `NotImplementedError`. It is a Gateway. `Repository` is for aggregates the
   service owns and persists.

8. **Scoped-repository proliferation.** A new `*ScopedRepository`, or the same
   `if is_admin(...)` / `if scope is None` branch copy-pasted across adapters. Owned-data tenant
   scope belongs in the read view's `WHERE` clause and in aggregate invariants — not in a
   per-repository decorator.

9. **Read side delegating to a write repository.** A query or view that takes a `*Repository` and
   forwards to it, or reconstitutes aggregates on a pure read path. Owned reads query the store
   directly; external reads go through a Gateway.

10. **Internal code reading through the query layer.** A view function no entrypoint reaches, or a
    command handler / dependency importing from the views module. The query layer serves externally
    reachable reads; internal callers use repositories and the domain.

11. **Authorization inside the command.** A command or DTO field like `allowed_*`, `permitted_*`, or
    a scope set. Commands carry intent only; scope is applied once, at a boundary.

## False-positive guards — do not flag these

- A scoped wrapper over an **external** read model is legitimate; only **owned-data** scoped
  repositories are the smell.
- The composition root / wiring module may be large. Size alone is not a finding.
- Distinct response DTO classes for endpoints with genuinely different wire shapes are fine.
- Frozen API-contract names (URL paths, JSON keys) are not "stale name" findings.
- Forward-only migration downgrades that cannot fully restore folded data are acceptable — forward
  is what production runs.
- A `type: ignore`, a raw primitive where a value object would fit, or any other local compromise
  that matches every neighbour in the file is the file's pattern, not this change's defect. Raise
  the pattern as a follow-up, not the line as a finding.

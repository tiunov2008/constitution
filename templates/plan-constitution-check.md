# Plan sections for the Engineering Constitution

Spec-kit's `plan-template.md` is not patched (CORE-71). When `/speckit-plan` fills its "Constitution
Check" and "Complexity Tracking" sections, it uses the formats below.

## Constitution Check

*Core and modules vX.Y.Z (modules: <list>); addendum vA.B.C. Filled before Phase 0 research and
re-checked after Phase 1 design.*

| Rule | How the plan meets it | Status |
|---|---|---|
| CORE-10 | <the checks the tasks run and where their output is recorded> | Pass |
| TS-07 | <...> | Pass with exception (Complexity Tracking) |
| TS-06 | <...> | SHOULD deviation: <reason> |
| CORE-43 | <what the project will need at promotion> | Deferred (production) |
| DOKPLOY-06 | <no deploy in this feature> | Not applicable |

List the NON-NEGOTIABLE rules (CORE-10 to CORE-13) and every core, module and addendum rule the feature
touches. Rules the feature does not touch are left out.

## Complexity Tracking

*Only for exceptions to a MUST (CORE-03). NON-NEGOTIABLE rules admit none.*

| Rule | Why the exception is needed | Simpler compliant option and why it was rejected | Removal condition | Owner approval |
|---|---|---|---|---|
| <ID> | <...> | <...> | <...> | <YYYY-MM-DD> |

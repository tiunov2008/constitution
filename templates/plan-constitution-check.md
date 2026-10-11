# Plan sections for the Engineering Constitution

Spec-kit's `plan-template.md` is not patched (CORE-71). When `/speckit-plan` fills its "Constitution
Check" and "Complexity Tracking" sections, it uses the formats below.

## Constitution Check

*Constitution vX.Y.Z (modules: <list>); addendum vA.B.C. Filled before Phase 0 research and re-checked
after Phase 1 design.*

| Rule | How the plan meets it | Status |
|---|---|---|
| CORE-10 | <the checks the tasks run and where their output is recorded> | Pass |
| CORE-11 | <stages, merges and deploys wait for the owner's command> | Pass |
| CORE-12 | <secrets and public surfaces the feature adds, or none> | Pass |
| CORE-13 | <migrations, data deleted or changed and its backup, or none> | Pass |
| TS-07 | <...> | Exception (Complexity Tracking) |
| CORE-22 | <...> | SHOULD deviation: <reason> |

List the NON-NEGOTIABLE rules (CORE-10 to CORE-13 and those of the addendum), then only the rules the
plan does not meet as written. A rule that is not listed is met. In a development project,
production-only rules are left out.

## Complexity Tracking

*Only for exceptions to a MUST (CORE-03). NON-NEGOTIABLE rules admit none.*

| Rule | Why the exception is needed | Simpler compliant option and why it was rejected | Ends or is reviewed when | Owner approval |
|---|---|---|---|---|
| <ID> | <...> | <...> | <...> | <YYYY-MM-DD> |

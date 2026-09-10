# TIDAL fork of openapi-generator

This repository (`tidal-music/openapi-generator`) is a **fork** of
[`OpenAPITools/openapi-generator`](https://github.com/OpenAPITools/openapi-generator).
It exists to carry a small set of Kotlin-client patches that the
`com.tidal.sdk:tidalapi` module in
[`tidal-music/tidal-sdk-android`](https://github.com/tidal-music/tidal-sdk-android)
depends on and that are not (yet) available upstream.

- **Upstream base:** upstream `master` at the **v7.23.0** release commit
  (`b9d967acc9a`).
- **Upstream remote:** `upstream` → `OpenAPITools/openapi-generator`.
- **Release scheme:** the CLI jar consumed by tidal-sdk-android is published as
  a GitHub Release named `tidal-SNAPSHOT-<YYYY-MM-DD>`, marked *latest*, with the
  asset `openapi-generator-cli.jar`.

## Guiding principle: keep this fork as close to upstream as possible

Every line we diverge from upstream is future merge-conflict debt and drift
risk. Minimize it:

1. **Prefer upstreaming.** Before adding a fork-only patch, check whether
   upstream already solves it, or would accept a contribution. A merged upstream
   fix is one we can drop from the fork.
2. **Keep patches surgical.** Touch the minimum templates/lines; gate on a
   single reliable signal rather than layering conditionals, so the patch
   re-ports cleanly onto the next upstream version.
3. **Rebase forward, don't accumulate.** Track upstream releases and move our
   patch set onto newer upstream tags rather than falling years behind.
4. **Record every divergence here.** Any new fork-only patch must be added to
   the table below, including whether it is upstreamable and what re-port it
   needs. The end state for any patch is "no longer needed because upstream has
   it."

## Current divergences from upstream

All current patches are in the **kotlin-client** generator
(`modules/openapi-generator/src/main/resources/kotlin-client/` and
`.../languages/KotlinClientCodegen.java`) and target
**kotlinx.serialization** output.

| Patch | Why | Key files | Introduced | Upstream status |
|---|---|---|---|---|
| **oneOf → sealed interface + `JsonContentPolymorphic`** | Upstream's Kotlin client does not generate working kotlinx.serialization polymorphism for `oneOf` schemas that use a **custom (non-`type`) discriminator**, or that share children across schemas. This patch wires oneOf children into a sealed interface and emits a `JsonContentPolymorphic` serializer so the tidalapi models deserialize. | `KotlinClientCodegen.java`, `Utils.kt.mustache`, `data_class.mustache`, `data_class_{req,opt}_var.mustache`, `interface_{req,opt}_var.mustache` | PR #2 (`95ca29a`, `8fafac6`) | **Not upstreamed.** Candidate for upstreaming; needs re-port onto upstream's plainer templates. |
| **`@Contextual` on free-form map value types** | For `additionalProperties: {}` maps, upstream emits a property-level `@Contextual`, which the kotlinx compiler plugin ignores → runtime crash *"Serializer for element of type kotlin.Any has not been found"*. This patch moves `@Contextual` onto the map **value type** (`Map<String, @Contextual Any>`). Replaces a manual post-generation hand-patch that used to live in tidal-sdk-android. | `data_class_{req,opt}_var.mustache`, `interface_{req,opt}_var.mustache` (+ test `KotlinClientCodegenModelTest.java`, `tm1938-freeform-map.yaml`) | PR #3 (`e4eb4ee`, `1b3b1ed`), TM-1938 | **Not upstreamed.** Same bug exists in upstream `master` (zero `isMap` handling); worth upstreaming, needs re-port onto upstream's plainer templates (no `x-is-transient` / `x-is-regular-interface`). |

Tidal-specific vendor extensions referenced by these templates
(`x-is-transient`, `x-is-regular-interface`) also originate in this fork's
history; they are consumed by the templates above.

## Working on the fork

- **Add a patch:** branch off `master`, make the change, add a codegen test
  (`modules/openapi-generator/src/test/.../KotlinClientCodegenModelTest.java` +
  a fixture under `src/test/resources/3_0/kotlin/`), and **add a row to the
  table above** with the rationale and upstream status.
- **Cut a release:** build the CLI jar
  (`./mvnw clean package -pl modules/openapi-generator-cli -am -DskipTests`
  → `modules/openapi-generator-cli/target/openapi-generator-cli.jar`) and create
  a `tidal-SNAPSHOT-<date>` GitHub Release marked *latest* with the asset named
  exactly `openapi-generator-cli.jar`.
- **CI note:** the "Samples up-to-date" check is expected-red repo-wide (the pom
  is at `7.23.0` while committed samples were generated at `7.23.0-SNAPSHOT`).
  It is pre-existing version-string noise, not caused by kotlin-client PRs.

## See also

The full generation pipeline (how tidal-sdk-android consumes this fork, the
auto-regeneration workflows, and the fix-a-broken-generator runbook) is
documented in the Tidal world model at
[`ops/tidalapi-code-generation.md`](https://github.com/squareup/tidal-world-model/blob/main/ops/tidalapi-code-generation.md).

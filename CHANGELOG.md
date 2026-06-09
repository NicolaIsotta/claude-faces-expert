# Changelog

## 1.2.3

### Knowledge Base — Updated
- **rules.md**:
  - **XML Namespaces**: strengthened to a directive — NEVER add `xmlns="http://www.w3.org/1999/xhtml"` as the default namespace on the page root in Faces 4.0+; it is implied by Facelets and leaks into rendered output.
  - **Facelets Rules**: new rule — composite component definition files (under `resources/<library>/<name>.xhtml`) MUST be rooted at `<ui:component>`, never `<html>`+DOCTYPE.
  - **Facelets Rules**: new rule — inside composite component definitions, use the prefix `cc` for `xmlns:cc="jakarta.faces.composite"`; avoid alternative prefixes (`composite`, `c`, `comp`).
  - **Facelets Rules**: clarified that JSTL tag handlers re-execute on every postback (the view tree is rebuilt each request), not only on the initial GET; `c:if`/`c:forEach` can depend on current request state, but heavy JSTL is a per-request cost.
  - **Component Rules**: new rule banning `prependId="false"` on `UIForm`; deprecated in Faces 5.0 (jakartaee/faces#1972) and breaks the `NamingContainer` namespace contract so `findComponent()` and ajax `execute`/`render` references no longer work from outside the form.
  - **Component Rules**: explained why programmatic tree manipulation is costlier than `rendered`/JSTL — components added/removed after the view is built become dynamic components that force a full-state save of the affected subtree on every postback.

## 1.2.2

### OpenCode Support
- New `install-opencode.sh` installer for [OpenCode](https://opencode.ai/) users.
- Creates `opencode.json` with instructions reference.
- Creates `AGENTS.md` as the primary rules file for OpenCode.
- Reuses the existing `.claude/faces/` layout via `install.sh`.
- Supports both project scope (`./opencode.json`, `./AGENTS.md`) and user scope (`~/.config/opencode/opencode.json`, `~/.config/opencode/AGENTS.md`).

## 1.2.1

### Knowledge Base — Updated
- **rules.md**: make sure that **View Metadata** subsection is self-contained (full explainer of `<f:metadata>` / `<f:viewParam>` / `<f:viewAction>`, lifecycle implication, common use cases, getter purity caveat).
- **lifecycle.md**:
  - Phase Shortcuts corrected: a GET request with at least one `<f:viewParam>` and/or `<f:viewAction>` runs the ENTIRE lifecycle, not just Restore View + Render Response.
  - Restore View phase: `<f:viewAction>` invocation timing fixed — invoked during Invoke Application, AFTER `<f:viewParam>` values are applied (not before Apply Request Values).
- **examples.md**: new **GET Search Form** example demonstrating `<f:metadata>` + `<f:viewParam>` + `<f:viewAction>` with a plain HTML `<form method="GET">` and a matching `@ViewScoped` backing bean.

## 1.2.0

### Installer
- `install.sh` now supports `--user` flag for installing into `~/.claude/` (applies to all projects). Default behavior (project-local install into `./.claude/`) is unchanged.
- Layout under `~/.claude/faces/` mirrors the project layout — same paths, same cross-references; no path rewriting needed.

### Knowledge Base — Updated
- **rules.md**:
  - New **Injectable Faces Types** subsection under CDI: typed `@Inject` targets, Servlet-provided types, `jakarta.faces.annotation` Map qualifiers, `@Inject @ManagedProperty`.
  - New **System Events and Phase Listeners** subsection: CDI `@Observes` with `@BeforePhase`/`@AfterPhase`/`@PreRenderView`, etc.
  - New **View Metadata** subsection: `<f:metadata>`, `<f:viewParam>`, `<f:viewAction>` with placement rules.
  - Faces 5.0 added to version lineage.
  - `@ClientWindowScoped` clarified: `jfwid` mechanism, semantics.
  - `/WEB-INF/resources` rule clarified: requires `WEBAPP_RESOURCES_DIRECTORY` context-param.
  - `UISelectMany` rule annotated with `UnsupportedOperationException` reason.
  - Cross-form `execute`/`process` clarified.

## 1.1.0

### Knowledge Base — New Topics
- **Lifecycle** (`topics/lifecycle.md`): request processing lifecycle — phases, shortcuts, ajax lifecycle, PhaseListener.
- **Conversion & Validation** (`topics/conversion-validation.md`): converters, validators, Bean Validation integration, cross-field validation, custom converters/validators.
- **Examples** (`topics/examples.md`): concrete code examples demonstrating best practices from the rules.

### Knowledge Base — Updated
- **rules.md**: reorganized structure; added `immediate="true"` guidance for `EditableValueHolder` and `UICommand`.
- **configuration.md**: added minimal `faces-config.xml` with `<locale-config>`.
- **omnifaces.md**:
  - New **Converters** section listing all OmniFaces converters.
  - New **Validators** section listing all OmniFaces validators.

## 1.0.0

Initial release.

### Knowledge Base
- Core rules (`rules.md`): terminology, view state, XML namespaces, CDI/bean management, scope selection, page authoring, resource rules, component rules, ajax rules, common errors, third-party library references.
- Configuration (`topics/configuration.md`): minimal web.xml, taglib, directory structure.
- Diagnostics (`topics/diagnostics.md`): decision trees for 6 common errors.
- PrimeFaces (`topics/primefaces.md`): PrimeFaces-specific rules and gotchas.
- OmniFaces (`topics/omnifaces.md`): OmniFaces utilities with when/how to use.

### Slash Commands
- `/faces-review`: review Faces code for mistakes, anti-patterns, and rule violations.
- `/faces-migrate`: migrate between Faces versions (JSF 1.x through Faces 4.1).

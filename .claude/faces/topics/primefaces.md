# PrimeFaces

*Version 1.5.0*

PrimeFaces is the most widely used component library for Jakarta Faces. When this project includes PrimeFaces, follow these rules.

## General

- PrimeFaces `UICommand` (e.g.`<p:commandButton>`) is ajax by default, unlike standard Faces `UICommand` (e.g.`<h:commandButton>`).
- Use `process` and `update` attributes (PrimeFaces names), not `execute` and `render` (standard names).
- For lazy-loading datatables: implement `LazyDataModel<T>` with `count()` and `load()` methods.
- As catch-all `UIMessages`, prefer `<p:growl>` or `<p:messages>` with `redisplay="false"`.
- For file downloads with ajax, use `<p:fileDownload>` which supports ajax since PrimeFaces 10; alternatively, disable ajax with `ajax="false"` on the `UICommand`.

## PrimeFaces Selectors

PrimeFaces Selectors `@(.css-class)` are very useful when you need to ajax-update multiple components on a particular event, you can create a marker class like `updateOnChangeFoo` and have `<p:inputText value="#{bean.foo}"><p:ajax update="@(.updateOnChangeFoo)"></p:inputText>` and add the marker class to the desired target components `<h:outputPanel id="somePanel" styleClass="updateOnChangeFoo">`.
The only condition is that the target component MUST have a ID set.

## Head Resources

NEVER use `<f:facet name="first">`, `<f:facet name="middle">`, or `<f:facet name="last">` inside `<h:head>`.
These are PrimeFaces-specific `HeadRenderer` extensions and are incompatible with other libraries (e.g. OmniFaces `CombinedResourceHandler`).
Instead, place any `<h:outputScript>` or `<h:outputStylesheet>` that must override library-provided resources inside `<h:body>`.
The `<h:outputScript>` additionally needs `target="head"`; it only relocates when `target` is set, otherwise it renders inline where declared.
The `<h:outputStylesheet>` has no `target` attribute at all; the standard `Stylesheet` renderer is required to relocate it into `<head>` unconditionally.
These will automatically be rendered as the last entries in `<h:head>`, after the resources contributed by PrimeFaces components, which is exactly why they must be declared in `<h:body>` and not in `<h:head>`.

## Dialogs and Overlays

`<p:dialog>` is NOT moved in the DOM unless you ask for it. `DialogBase#getAppendTo()` evaluates to `null` when the attribute is absent, `WidgetBuilder#attr()` writes nothing for a `null` value, so the widget config carries no `appendTo` at all, and `PrimeFaces.utils.registerDynamicOverlay()` relocates nothing without one — the `@(body)` that `DialogBase` documents as an implicit default never takes effect. As of 13.0, `DynamicOverlayWidget#init()` additionally exempts `Dialog` (subclasses included, an `instanceof` check) from the `resolveAppendTo()` fallback the other overlays get. Verified across PrimeFaces 8 through 16.
With `modal="true"` the modal mask (`<div class="ui-widget-overlay ui-dialog-mask">`) IS appended to `<body>`, which is what makes it look as though the dialog moved; a non-modal dialog produces no mask.

The form requirement follows from `appendTo`; there is no blanket "a dialog must carry its own form" rule:

- **No `appendTo` (the default)**: the dialog stays where the view puts it. Inside an `<h:form>` it submits through that form and needs NO form of its own — adding one would nest forms, which is invalid. PrimeFaces' own integration tests are written that way: one `<h:form>` around `<p:dialog>` with a `<p:commandButton update="@form">` inside it.
- **`appendTo="@(body)"`**: the dialog is moved to the end of `<body>` on widget init and lands outside the form it was declared in, so it MUST have its own `UIForm`. The symptom is silent rather than loud: the form of a command is resolved SERVER-side from the component tree, so the request reaches the right form and the action does run, but the request body is serialized from that form ELEMENT in the DOM, which no longer contains the dialog — every value in it is dropped. `partialSubmit="true"` helps only when `process` names components inside the dialog (`@parent`, or the input ids): a command without `process` submits `@all`, and the partial-submit branch in `core.ajax.js` is skipped whenever the process ids contain `@all`, while `process="@form"` serializes that same form element — both drop the values regardless. A plain `<h:commandButton>` there does nothing at all, being a `type="submit"` outside every form. Because forms must not be nested, declare such a dialog OUTSIDE the other `<h:form>` in the view as well: the browser's HTML parser drops a nested `<form>` start tag outright, so a form declared inside another one never exists to be moved along. Use `@(body)` when the dialog is clipped by a positioned or `overflow: hidden` ancestor (`<p:tabView>`, `<p:accordionPanel>`, a table cell), or when a dialog opens another dialog.
- **`appendTo="@form"`**: resolved server-side to the enclosing form's client id, so the dialog is appended to the end of its own form and stays in a form context. No form of its own, and nothing to move in the view.
- **`appendTo="@(form)"`**: `@(...)` is a jQuery selector evaluated in the browser, so this matches EVERY `<form>` in the document, not the enclosing one — and with more than one form, jQuery CLONES the dialog into each of them, duplicating client ids. Write `@form` when that is what was meant.

Do NOT generalize any of this to "overlay components"; the families differ:

- **Moved only inside a dialog**: `<p:overlayPanel>`, `<p:confirmPopup>` and `<p:sidebar>` have no `appendTo` default; as of 13.0, `resolveAppendTo()` forces `@(body)` when, and only when, their target sits inside a `.ui-dialog`. Elsewhere they stay where they are rendered unless `appendTo` is set.
- **Always moved**: the panel inputs `<p:selectOneMenu>`, `<p:selectCheckboxMenu>`, `<p:autoComplete>`, `<p:datePicker>`, `<p:cascadeSelect>` and the button menus `<p:menuButton>`, `<p:splitButton>` — their `*Base#getAppendTo()` defaults to `@(body)`, so the renderer always emits it. So do `<p:menu overlay="true">`, `<p:tieredMenu overlay="true">` and `<p:slideMenu overlay="true">` via `BaseMenu#initOverlay()`, and `<p:contextMenu>`, which sets `@(body)` on itself and skips `initOverlay()` for exactly that reason. Harmless for the menu itself, since a `<p:menuitem>` posts its declared form and no values of its own, but an input placed inside such a menu leaves its form exactly as a moved dialog's does.
- **Never moved**: `<p:dialog>`, which moves only when `appendTo` says so.
- `<p:confirmDialog global="true">` is the one dialog that really does default to `@(body)`; a non-global one behaves exactly like `<p:dialog>`.

## CSS

ALWAYS load the CSS file with custom definitions via `<h:outputStylesheet>` inside `<h:body>` (it has no `target` attribute; that only exists on `<h:outputScript>`).
When overriding PrimeFaces-specific CSS, ALWAYS use the exact same selector PrimeFaces is using, and use a separate CSS file from user-defined classes, e.g. `primefaces-overrides.css`.

## JavaScript

When patching PrimeFaces widget JavaScript (e.g. to fix a client-side bug or tweak rendering), ALWAYS use the official `extend()` pattern, NEVER reach into `prototype` directly and NEVER poll/wait for the widget to appear:

```javascript
if (PrimeFaces.widget.Slider) {
    PrimeFaces.widget.Slider = PrimeFaces.widget.Slider.extend({
        onSlide: function (event, ui) {
            // override here; call this._super(event, ui) to delegate
        }
    });
}
```

Place such patches in a dedicated file (e.g. `primefaces-patches.js`) and load it via `<h:outputScript target="head">` inside `<h:body>` so it runs after the PrimeFaces core script. The `if (PrimeFaces.widget.X)` guard is sufficient because the widget script is loaded together with PrimeFaces core; no polling or `setInterval` workaround is needed.

## References

- Source code: https://github.com/primefaces/primefaces
- Java API: https://javadoc.io/doc/org.primefaces/primefaces/latest/index.html
- VDL (tag docs): https://primefaces.github.io/primefaces/vdldoc/
- Showcase with examples: https://showcase.primefaces.org

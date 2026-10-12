---
name: data-analysis-design
description: A complete visual design for data-heavy applications - dashboards, tables, review queues, charts and graph views - with a warm monochrome canvas, colour reserved for data, semantic status pastels, a derived category palette, dense typography with tabular numerals, Bootstrap 5.3 themed to the tokens, a viewport-locked shell with fixed breakpoints, and one generic set of view states. Load before writing a project's design direction, and before designing, implementing or reviewing any screen, component or stylesheet. The intro table says which sections each role applies.
metadata:
  version: "1.0.0"
---

# Data-analysis design

A design for working tools: software one person uses at a desk to curate data, read it and explore
it. The language is quiet, editorial and utilitarian. The canvas is warm monochrome and colour is
spent only where it carries data. Everything here is a value or a rule that can be checked.

The project's `docs/ux.md` Section 1 is the authority on design direction. A project adopts this
skill by saying so there and listing only its deviations; it does not copy these tables. Where
`docs/ux.md` and this skill disagree, `docs/ux.md` wins. Where a requirement, a contract or a story
conflicts with this skill, that is specification drift to report, never to resolve silently.

## When to load this skill, and what each role owes it

| Role | Load it before | Obligation |
|---|---|---|
| Design/UX Agent | writing `docs/ux.md` Section 1, specifying a surface, or writing any markup, component or stylesheet | Apply Sections 1 to 8. Record the adoption and every deviation in `docs/ux.md` Section 1. Never introduce a colour, size, radius, shadow or breakpoint these sections do not list |
| Software Architect | designing the frontend's styling and layout contracts | Section 9 is the default integration. Decide it, record it as design decisions, and name the files that hold the tokens, the theme and the components |
| Developer | editing anything that renders or styles the interface | Apply Sections 2 to 8. A change that needs a new token, breakpoint or dependency is a design gap for the Software Architect, not a local decision |
| Code Review Agent | reviewing a change that touches the interface | Run the Section 10 checklist in full. Each "no" is a finding at Major severity or above, cited by file and line |

## 1. Design direction

| Dial | Value | Meaning |
|---|---|---|
| Variance | 3 of 10 | A tool, not a landing page. Predictable grid, consistent panel anatomy |
| Motion | 2 of 10 | Motion only where it carries meaning (Section 8). No scroll reveals, no staggered entrances |
| Density | 7 of 10 | Data-dense. Compact rows, 14 px base text, tabular numerals, 16 to 24 px gutters |

- **Trust in the numbers is the product.** Every aggregate shows how much of its value is unknown,
  pending or in conflict, and one click leads to fixing it.
- **Density over decoration.** No decoration without function: no gradients, no coloured icon
  tiles, no decorative sparklines, no hero sections, no footer tagline, no refresh button.
- **Colour is reserved for data.** Chrome is monochrome. A colour on screen means a status or a
  category, and never both with the same hue.
- **Every chart is also a filter.** Clicking a mark narrows the view and adds a chip to the filter bar.
- **Text first.** An icon appears only where the specification names one. No emoji.
- **One role at a time is obvious.** Curating, analysing and exploring are separate surfaces with
  the same shell around them, so switching never changes how the page behaves.

## 2. Tokens

**Surfaces and text**

| Token | Value | Use |
|---|---|---|
| `--canvas` | `#FBFBFA` | Page background |
| `--surface` | `#FFFFFF` | Panels, tables, dialogs, chart and graph stages |
| `--surface-sunken` | `#F7F6F3` | Filter bars, table headers, card headers, hover and selected-row tint |
| `--border` | `#EAEAEA` | Every panel border and divider, 1 px |
| `--border-strong` | `#D9D8D4` | Input borders, secondary-button borders, graph links |
| `--ink` | `#111111` | Primary buttons, headings, key figures, the active marker |
| `--text` | `#2F3437` | Body text |
| `--text-muted` | `#6B6A66` | Secondary text, labels, axis text |
| `--focus` | `#111111` | 2 px outline with 2 px offset on the active control |

**Status pastels** (status only, never a category)

| Meaning | Background | Text |
|---|---|---|
| Pending, awaiting a decision, warning | `#FBF3DB` | `#956400` |
| Error, conflict | `#FDEBEC` | `#9F2F2D` |
| Done, confirmed, classified | `#EDF3EC` | `#346538` |
| Informational, planned, differs from the default | `#E1F3FE` | `#1F6C9F` |
| Neutral: unknown, ignored, inactive | `#F1F1EF` | `#5A5955` |

**Typography**

- Sans: `"Geist", "SF Pro Text", "Helvetica Neue", system-ui, sans-serif`. Mono:
  `"Geist Mono", "SF Mono", ui-monospace, monospace`. No serif. The stack must look right on its
  system fallback alone; a named font is bundled with the application or not used.
- Scale in px: 12 (meta, badges, axis text), 13 (table cells), 14 (base), 16 (panel titles),
  20 (view headings), 28 (key figures). Line height 1.45 for interface text, 1.6 for prose.
- Headings are weight 600 in `--ink`. Section labels inside dialogs are 11 px, weight 600,
  uppercase, letter-spacing 0.06em, in `--text-muted`.

**Shape, elevation and controls**

- One radius scale: 6 px for inputs and buttons, 8 px for panels, a full pill only for status badges.
- Panels have a 1 px `--border` and no shadow. Only what overlays content has a shadow:
  `0 8px 24px rgba(0, 0, 0, 0.06)` on dialogs, menus, side panels and floating chrome.
- Scrims: `rgba(17, 17, 17, 0.08)` for a light overlay, `rgba(17, 17, 17, 0.16)` behind a dialog.
- Primary button: `--ink` fill, white text. Secondary: white with `--border-strong`. Destructive:
  the secondary style with `#9F2F2D` text, never a red fill.
- Tooltip: `--ink` background, white 12 px text, 6 px radius.

## 3. Colour roles

- **Status** uses the pastels of Section 2 as pill badges. A status badge is never the only cue for
  something the user must act on: a count or a link sits beside it.
- **Category** uses the derived palette of Section 4, on swatches, chart marks, bars and accents.
- **Red means error or conflict.** It never means large, negative or outgoing. A quantity is drawn
  in `--ink` or `--text` whatever its direction.
- **A signed value prints its sign** (`+2 000,00`, `−1 234,50`), so colour is never the only
  carrier. A favourable or incoming value may take `#346538`.
- **A two-series comparison** (in against out, actual against target) uses `#346538` for the
  favourable series and `#2F3437` for the other. These are semantic, not category colours.
- **The informational blue** `#1F6C9F` on `#E1F3FE` marks what is planned or not yet real. A planned
  mark is also told by shape: white fill, a contour, dashed lines (`5,3`) and a text pill.
- A drawing surface that cannot read a custom property (canvas, some SVG output) uses the literal
  value, with a comment naming the token.

## 4. Category colour is derived, never stored

No colour is hardcoded per category, so the palette survives any change to the category list.

1. Take the categories in a stable order defined by the data (their identifiers), never by label
   and never by which categories happen to have values in the current view.
2. The top-level category at index `i` takes palette slot `i mod 9`.
3. A child category takes its parent's hue; its siblings, in the same stable order, get evenly
   spaced tints by interpolating the parent colour toward `#FFFFFF` in Lab space, from 0.0 to
   0.55. A single child gets 0.
4. "Unknown" or uncategorised is always `#A8A6A0` with a 45-degree hatch. Hatching means "not known yet".
5. With more than nine top-level categories the slots repeat with a dotted overlay on the second cycle.
6. A grouping bucket such as "Other" is `#C7C5BF`. It is not a category and takes no slot.

| Slot | Hex | Slot | Hex | Slot | Hex |
|---|---|---|---|---|---|
| 0 | `#3E6FA3` | 3 | `#8A5FA0` | 6 | `#B8952A` |
| 1 | `#C9702E` | 4 | `#B84A4A` | 7 | `#8C6A55` |
| 2 | `#4E8A57` | 5 | `#3D8C8C` | 8 | `#C76B8E` |

- One category has one colour everywhere: charts, tables, ranked lists and the graph.
- Colours are keyed by identifier, so a change of label or language never changes them.
- Every coloured mark has a label, a legend row or a tooltip.
- A component receives a category colour as a per-element custom property (`--cat`) or as an
  inline colour on a chart mark. It is never mapped onto a theme colour, so status and category
  can never share one.

## 5. Numbers and data text

- `font-variant-numeric: tabular-nums` wherever numbers align; numeric columns are right-aligned.
- One number format for the whole product, set by the project's locale and applied in one place.
  The unit or currency is shown once per panel header, not on every value.
- Totals shown to the user come from the backend. The interface converts a value to a number only
  for scales and drawing and never re-sums.
- Text that came from an outside source unchanged (an imported description, an identifier, a
  pattern) is set in the mono face, so what the source said is always distinguishable from what
  the product says.
- A missing value is a muted, italic placeholder, never an empty cell.

## 6. Components: Bootstrap 5.3, themed

The component vocabulary is Bootstrap 5.3: `card` (with `card-header`, `card-body`,
`card-footer`), `list-group`, `badge`, `nav-tabs`, `btn` and `btn-group` (with `btn-check` for a
segmented choice), `form-check` and `form-switch`, `form-control`, `collapse`, `progress`,
`dropdown`. Screens are specified in these terms: a section of a panel is a card, a ranked list is
a list group, a segmented choice is a button group, an on-off option is a switch. Bootstrap is
themed to the tokens and never appears with its default blue look.

| Token | Bootstrap variable |
|---|---|
| `--canvas` | `--bs-body-bg` |
| `--surface` | `--bs-card-bg`, `--bs-list-group-bg`, `--bs-dropdown-bg`, `--bs-nav-tabs-link-active-bg` |
| `--surface-sunken` | `--bs-secondary-bg`, `--bs-tertiary-bg`, `--bs-card-cap-bg` |
| `--border` | `--bs-border-color`, `--bs-card-border-color`, `--bs-list-group-border-color` |
| `--border-strong` | The border of `.form-control`, `.form-check-input` and `btn-outline-secondary` |
| `--ink` | `--bs-primary`, `--bs-emphasis-color`: primary button fill, checked inputs, active switch, active tab marker |
| `--text`, `--text-muted` | `--bs-body-color`, `--bs-secondary-color` |
| Focus | `--bs-focus-ring-color: rgba(17, 17, 17, .2)` |
| Done pair | `--bs-success-bg-subtle`, `--bs-success-text-emphasis`, `--bs-success` |
| Pending pair | `--bs-warning-bg-subtle`, `--bs-warning-text-emphasis` |
| Error pair | `--bs-danger-bg-subtle`, `--bs-danger-text-emphasis`, `--bs-danger` |
| Informational pair | `--bs-info-bg-subtle`, `--bs-info-text-emphasis` |
| Neutral pair | `--bs-light`, with `#5A5955` text |
| Radii | `--bs-border-radius-sm: 6px`, `--bs-border-radius: 8px`, `--bs-border-radius-lg: 10px`, pill for status badges only |
| Type | `--bs-body-font-family`, `--bs-font-monospace`, `--bs-body-font-size: .875rem`, `--bs-body-line-height: 1.45` |
| Elevation | `--bs-card-box-shadow: none`; `--bs-box-shadow: 0 8px 24px rgba(0, 0, 0, .06)` |

- **Status badges are the subtle pills**: `badge rounded-pill bg-success-subtle
  text-success-emphasis`, and likewise warning, danger, info and light. `text-bg-*` is not used,
  because it fills with the strong colour.
- **Density.** Default control sizes in panels and side panels; the small size only inside dense
  list rows. Table cells stay at 13 px with 6 px by 8 px padding and a hairline under each row.
- **Bootstrap's grid and layout utilities are not used** for the shell or for view layout. The
  layout system of Section 7 is the only one.

## 7. Layout

**Shell.** The shell is exactly the viewport: a column of rows with `height: 100dvh`. The rows are
the header (56 px, full width, a bottom border, never wrapping), a banner row (zero height when
empty) and the main area, which takes the rest. The document never scrolls; each view decides what
scrolls inside the main area. In the header the active tab has a 2 px `--ink` underline. A banner
is a full-width strip under the header in the error pastel: one sentence and one action. It pushes
the main area down and never overlays content.

**Breakpoints.** One set, used everywhere. A view never invents its own.

| Range | Name | Support | Gutter | Panel gap |
|---|---|---|---|---|
| 1440 px and up | wide | Design target | 24 px | 16 px |
| 1280 to 1439 px | standard | Fully working | 24 px | 16 px |
| 1024 to 1279 px | compact | Minimum fully supported width | 16 px | 12 px |
| 768 to 1023 px | narrow | Degraded but not broken: everything reachable, nothing overlaps, layouts drop to one column | 12 px | 12 px |
| Below 768 px | phone | Only the views the specification names; the others keep a 768 px minimum and scroll sideways | 12 px | 12 px |

- Gutter and panel gap are tokens whose values change per range. Components use the tokens.
- Minimum supported height is 640 px. Below it nothing is redesigned.
- **A range is measured on the width a piece actually has.** Shell pieces use the viewport width.
  Everything inside a view uses the main area's width, so a view beside an open side panel behaves
  as it would in a window of that width. This is one set of ranges, not two breakpoint systems.
- A threshold inside one panel (a chart beside or above its table at 560 px) is a container query
  on that panel, never a viewport query.

**Two layout modes.** Every view declares one; the shell applies it, so a view never sets its own
outer padding or maximum width.

- **Fluid content** (tables, dashboards, forms): the main area scrolls vertically. Content is
  centred with the gutter on both sides, a maximum width of 1600 px, 16 px top and 48 px bottom
  padding. Panels take the full content width; only prose-only panels are capped at 720 px. A view
  starts with one compact title row: a 20 px heading with the view's actions on the right.
- **Full-bleed canvas** (a graph or map stage): the view fills the main area exactly, with no
  gutters, padding, title row or border. Nothing scrolls; the wheel zooms. All chrome floats over
  the stage on `rgba(255, 255, 255, 0.94)` with a border, an 8 px radius and the overlay shadow,
  12 px from the edges. Empty, loading and error states are centred in the visible region with the
  floating toolbar still in place.

**Sticky regions** stick to the main area, not the document: a filter bar to the top, a table's
column header below it, a bulk action bar to the bottom while a selection exists.

**Widths of shared pieces**

| Piece | 1280 px and up | 1024 to 1279 px | 768 to 1023 px |
|---|---|---|---|
| Dashboard grid | 12 columns, a sticky rail of 5 beside 7 | 6 columns, two panels side by side, the list full width | 1 column |
| Key-figure strip | 4 cells in a row | 4 cells in a row | 2 by 2 |
| Data table | All default columns | The lowest-priority column hidden, still in the row details | Two hidden; a status shrinks to a 6 px dot |
| Side panel over a canvas | Open, 480 px (400 to 720 px, at most half the stage) | Collapsed by default | Collapsed; opens at `min(480px, 100% − 48px)` |
| Dialog | 560 px, centred | 560 px, centred | `min(560px, 100% − 48px)` |

**Overlay layers.** One stacking order, lowest first. Each layer is a token; no component picks its
own z-index.

| Token | Value | Contents |
|---|---|---|
| `--z-content` | 0 | View content, the stage |
| `--z-sticky` | 10 | Sticky regions |
| `--z-chrome` | 20 | Floating chrome over a canvas |
| `--z-sidepanel` | 30 | Side panels |
| `--z-shell` | 40 | Header and banner row |
| `--z-popover` | 50 | Dropdowns, pickers, context menus |
| `--z-modal` | 60 | Scrim and dialog |
| `--z-toast` | 70 | Toasts, bottom centre of the main area |
| `--z-tooltip` | 80 | Tooltips |

A layer owns a band of ten; an offset inside it is written `calc(var(--z-sticky) + 2)`. Popovers,
menus and tooltips open inside the viewport and flip when they would cross its edge. A popover
opened from a dialog belongs to the dialog and is drawn above it.

## 8. Data views, states and motion

**Data-view patterns**

| Pattern | Design |
|---|---|
| Key-figure strip | One flat strip of cells divided by hairlines, no icon tiles. A 12 px uppercase label, a 28 px figure, and a 13 px comparison with the previous period at the same granularity, with a neutral "No comparison data" state |
| Filter bar | Sunken surface. The time control comes first and is the largest. Chips are added by clicking chart elements |
| Category breakdown | A clickable two-level donut (220 px) beside a ranked table. The unknown share is always shown, hatched |
| Trend | Lines at the selected granularity with direct line-end labels and the selected period marked. Axis text 12 px muted; gridlines in `--border` |
| Ranked list | Bar rows with amounts, labelled so they are not read as adding up to the total when they do not |
| Data table | Sticky header on the sunken surface, 13 px cells, hairline rows, hover and selection in the sunken tint, details expanding in place |
| Graph view | Feels like a graph database browser, not a decorative network. White stage, nodes coloured by category, links in `--border-strong`, floating chrome |

**States.** There are no per-panel empty, loading or error designs. Every panel, table, chart and
stage uses one generic message per state. A state that is not one of these three keeps its own
specified presentation.

| State | Presentation |
|---|---|
| Empty | "Nothing to show for the current selection." |
| Loading | Skeleton placeholders in the panel's final shape, never a spinner, with "Loading…" |
| Error | "Couldn't load: {reason}. [Retry]", where the reason is a cause category from the API, never query text or a raw error body |

Every state a surface can be in (empty, loading, failed, partial, updating) is designed. A surface
that only implements the happy path is incomplete.

**Motion** is allowed only where it carries meaning: a force layout settling, a dialog step
change, a row changing status, a row expanding, a chart cross-fading between levels, a side panel
sliding (160 ms). Hover transitions are 150 ms.

## 9. Default integration (the Software Architect decides)

- **Tokens** are CSS custom properties on `:root` in one base stylesheet, the only place their
  values are written. Layout tokens change per range by overriding them there.
- **Bootstrap is compiled from its Sass sources as a component subset**, themed with Sass
  variables set from the tokens before Bootstrap's own variables load. The precompiled stylesheet
  is not used: it always brings Reboot, the grid and every utility, and its component colours are
  compiled in, so theming by custom properties alone drifts. A small Sass partial repeats the
  colour tokens, because Sass colour functions cannot read custom properties; a test asserts the
  two copies agree.
- **Compiled:** buttons, button group, forms, card, list group, badge, nav, progress, dropdown,
  close, and a whitelist of utilities (colour, background, border, font weight, text alignment).
  **Never compiled:** Reboot, grid, containers, tables, modal, offcanvas, tooltip, popover, toasts,
  and the position helpers.
- **No Bootstrap JavaScript** and no wrapper library that positions its own overlays. Open and
  shown state belongs to the application's component framework. Popovers are placed by one shared
  placement helper on the popover layer.
- **Thin presentational components** render the Bootstrap class names (button, card, badge, list
  group, switch, segmented control, tabs, dropdown, icon). A screen reuses one before writing
  Bootstrap classes by hand.
- **Stylesheet order:** the Bootstrap subset, then the icon font, then the base stylesheet, then
  the feature stylesheets, all imported from one entry module, so the project's rules win at equal
  specificity. The base stylesheet never styles a Bootstrap class name.
- **Breakpoints** exist as constants in code and as media-query literals; the two are kept equal.
  A view's range rule is written against an attribute the shell sets on the main area, inside
  `:where()` so it keeps the specificity a media query would have had.
- **Icons** are Bootstrap Icons, bundled with the application.

## 10. Review checklist (Code Review Agent)

Answer each with yes or no; a "no" is a finding.

1. Every colour, size, radius, shadow and z-index in the change is a token from Section 2 or 7, or
   a literal on a surface that cannot read a custom property, with a comment naming the token.
2. Status colour comes only from the pastels; category colour comes only from the derived palette;
   no value is red because it is large, negative or outgoing.
3. Category colours are derived from a stable order and keyed by identifier; none is hardcoded.
4. Numbers that align use tabular numerals, are formatted in one place, and no total is re-summed
   in the interface.
5. Bootstrap elements go through the project's components; the grid and layout utilities are unused.
6. No new viewport breakpoint; a view's range follows the main area's width; a threshold inside a
   panel is a container query.
7. The view declares one layout mode and sets no outer padding, maximum width or document scroll.
8. Overlays use the layer tokens and open inside the viewport.
9. Empty, loading and error use the generic states; loading is a skeleton; no raw error text is shown.
10. No decoration without function was added, and no motion outside Section 8.

## 11. Where the project records it

| Thing | Where |
|---|---|
| That the project uses this design, and every deviation from it | `docs/ux.md` Section 1 |
| The integration decisions of Section 9 | The design decisions of the low-level design |
| The files that hold the tokens, the theme, the components and the breakpoint constants | The project conventions of the low-level design, or a project skill that describes the wiring |
| The number format and locale, and which views work at phone width | `docs/ux.md` |

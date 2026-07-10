# Color and theme

How a Power BI theme JSON is built, how to apply and validate the house theme, and the color
and font rules. The ready made theme is `guidelines/house-default-theme.json`.

## How a theme JSON is structured

A theme file has one required key, `name`. Everything else is optional, and any slot you leave
out keeps the Power BI default. Microsoft groups the rest into four parts.

1. Theme colors. The data palette and the status and gradient slots.
   - `dataColors`: an array of hex codes for the series in visuals. It can hold as many colors
     as you want. When they run out, Power BI generates more by shifting saturation and hue.
   - Sentiment slots `good`, `neutral`, `bad`: the status colors used by the waterfall chart
     and the KPI visual.
   - Divergent slots `minimum`, `center`, `maximum`, and `null`: the gradient endpoints in the
     conditional formatting dialog. In DAX these are referenced as `minColor`, `midColor`,
     `maxColor`, and `nullColor`.
2. Structural colors. The frame of the report.
   - `background` and `secondaryBackground`: page and element backgrounds.
   - `foreground` (also called `firstLevelElements`): primary text, card labels, trend lines.
   - `foregroundNeutralSecondary` (also called `secondLevelElements`): axis and legend labels,
     table headers.
   - `tableAccent`: the table and matrix grid outline.
3. Text classes. Under `textClasses`, set the four primary classes and the rest inherit.
   - `callout`: card data labels and KPI indicators. This is the big number.
   - `title`: axis and visual titles.
   - `header`: tab and matrix style headers.
   - `label`: table and matrix values and general text.
   - Each class takes `fontFace`, `fontSize`, and `color`.
4. Visual styles. Under `visualStyles`, set per visual defaults, for example turn off data
   labels on line charts or set a default gridline style. This is where a theme goes from a
   color swap to a real design system. Keep it lean and set only what you want to change.
   A rule can target one visual type by name, not just the `*` wildcard. A useful pattern is a
   subtle rounded border on every visual, turned off for the image visuals so a logo has no box:

   ```json
   "visualStyles": {
     "*":     { "*": { "border": [ { "show": true, "radius": 8, "color": { "solid": { "color": "#E1DFDD" } } } ] } },
     "image": { "*": { "border": [ { "show": false } ] } }
   }
   ```

Note. You cannot put conditional formatting rules in a theme. The theme sets the gradient
colors, but you still apply the rule on each visual.

## Apply the house theme

In Power BI Desktop, go to View, Themes, Browse for themes, and pick
`guidelines/house-default-theme.json`. From then on every new visual inherits its colors and
fonts. What the house theme encodes:

- `dataColors` is the Okabe-Ito colorblind safe categorical palette (blue, orange, green,
  vermillion, sky blue, reddish purple, yellow, black). These stay distinct for the common
  forms of color vision deficiency and in grayscale.
- The diverging scale runs blue at `minimum` to a light center to orange at `maximum`. It
  deliberately avoids red to green, which is the pairing most colorblind readers cannot tell
  apart.
- `good` is green and `bad` is vermillion (a red orange), so positive and negative still read
  without relying on a true red and green.
- Segoe UI across the text classes, at a tight size scale.

A trimmed view of the shape:

```json
{
  "name": "ABC House Default",
  "dataColors": ["#0072B2", "#E69F00", "#009E73", "#D55E00", "#56B4E9", "#CC79A7", "#F0E442", "#000000"],
  "good": "#009E73", "neutral": "#8A8886", "bad": "#D55E00",
  "minimum": "#0072B2", "center": "#F0F0F0", "maximum": "#D55E00",
  "background": "#FFFFFF", "secondaryBackground": "#F3F2F1",
  "foreground": "#252423", "foregroundNeutralSecondary": "#605E5C",
  "tableAccent": "#0072B2",
  "textClasses": {
    "callout": { "fontFace": "Segoe UI Semibold", "fontSize": 28, "color": "#252423" },
    "title":   { "fontFace": "Segoe UI Semibold", "fontSize": 14, "color": "#252423" },
    "header":  { "fontFace": "Segoe UI Semibold", "fontSize": 12, "color": "#252423" },
    "label":   { "fontFace": "Segoe UI",          "fontSize": 10, "color": "#252423" }
  }
}
```

## Color rules

- Three to five purposeful colors per page, each with a fixed meaning. Gray for context, one
  accent for the thing in focus, and red and green reserved for negative and positive.
- Keep the semantic encoding. Do not let a brand color override a meaning slot. If the brand is
  blue, that does not make `bad` blue. The status slots exist so bad always looks bad.
- Default to colorblind safe palettes. Okabe-Ito for categorical series, and a ColorBrewer
  colorblind safe set for sequential or diverging scales.
- Test a palette before you commit. Paste it into Viz Palette to simulate color vision
  deficiency, or build sequential and diverging ramps in ColorBrewer. Links in
  `guidelines/sources.md`.
- Never use color as the only signal. Back it with a label, an icon, or position. See
  `references/accessibility.md`.

## Validate the theme JSON

Power BI validates a theme on import and rejects fields it does not understand. Catch problems
before that by validating against the official schema. Download `reportThemeSchema.json` from
the Report Theme JSON Schema folder in `microsoft/powerbi-desktop-samples`, put it next to your
theme, and add the reference:

```json
{
  "$schema": "./reportThemeSchema.json",
  "name": "ABC House Default"
}
```

In VS Code this gives autocomplete on every slot and flags an invalid property as you type. It
is the fastest way to author `visualStyles` without guessing card and property names.

## Fonts

- Segoe UI for text is the Power BI default and reads well. DIN is the default for numbers on
  cards and axes. Keep to one or two families and a tight size scale.
- Custom fonts may not render on non Windows clients, on the web, or on mobile, and they fall
  back to a substitute that can break your layout. Prefer a web safe sans serif for anything
  that must travel. The house theme keeps Segoe UI across all four text classes for exactly
  this reason, rather than leaning on DIN for the callout.
- Make the hierarchy obvious. Large bold KPI values, medium headings, smaller secondary text.
  Do not center long text. Left align for reading.

## Pro vs Premium

Building, applying, and validating a theme is all Pro. The free theme generators in
`guidelines/sources.md` are Pro friendly. Applying a theme to a published dataset over XMLA, or
extracting a theme programmatically through Semantic Link Labs in a Fabric notebook, needs
Fabric or Premium. Any Copilot assisted color or narrative feature needs a Fabric capacity too.

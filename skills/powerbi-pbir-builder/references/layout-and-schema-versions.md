# Layout, z order, and schema versions

Canvas sizes, the grid numbers a dense report actually uses, the z and tab order conventions
Power BI Desktop itself writes, and how to avoid hardcoding a schema version.

The numbers here are measured from a live 22 page report, not proposed. Where a range is given,
pick one and hold it across every page, because consistency is what makes a report feel like one
document.

## Canvas

16 by 9, `1280 by 720` as the default. Use `1920 by 1080` only for a report meant to fill a
large screen, and `320 by 240` for a tooltip page.

Every `page.json` also carries a display option. `FitToPage` is the usual choice and it should
be the same on every page:

```json
{ "name": "pgOverview", "displayName": "Overview",
  "width": 1280, "height": 720, "displayOption": "FitToPage" }
```

## Margins and gutters: pick a density and commit

There are two workable systems. Both keep every value a multiple of 8.

**Dense operational, 8 and 8.** Margin 8 on all four sides, gutter 8 between visuals. This is
what a working operational report uses across 22 pages, and it fits far more on a page without
looking cramped, because the container padding and border radius do the visual separation
instead of white space. Full width content is `x: 8, width: 1264`. Full height content is
`y: 8, height: 704`.

**Airy executive, 24 and 16.** Margin 24, gutter 16. Better for a page with four or five
visuals that someone reads from across a room.

Do not mix them in one report.

### The vertical bands that follow from a header strip

A row of slicers across the top, then content below it, produces three repeating layouts. The
content starts exactly one gutter below the strip.

| Header strip height | Content `y` | Content `height` | Bottom edge |
| --- | --- | --- | --- |
| 56 | 72 | 640 | 712 |
| 64 | 80 | 632 | 712 |
| 72 | 88 | 624 | 712 |

A vertical stack of slicers down the left uses a 64 pixel pitch, that is 56 tall plus an 8 gap,
so they sit at `y` 80, 144, 208, 272, 336.

### Content splits that recur

On a 1280 canvas with an 8 margin, these are the divisions that land on the grid.

| Split | Values |
| --- | --- |
| Full width | `x: 8, width: 1264` |
| Full width after a 128 left rail | `x: 144, width: 1128` |
| Two columns, equal | `x: 8, w: 624` and `x: 648, w: 624` |
| Two columns, asymmetric | `x: 8, w: 768` and `x: 792, w: 480` |
| Three columns | `x: 8, w: 560`, `x: 576, w: 320`, `x: 904, w: 368` |
| Two rows, equal | `y: 88, h: 312` and `y: 400, h: 312` |
| Chart, thin card, chart | `y: 88, h: 296`, then `y: 392, h: 32`, then `y: 432, h: 280` |

A left rail width `w` puts content at `x = 8 + w + 8`. Rails of 88, 128, 272, 280, and 328 all
work.

### A KPI row is optional

A row of four cards at `y: 24, height: 120, width: 296`, spaced 312 apart, is a good summary
page. It is not mandatory, and a report can be excellent without one. The live report has no KPI
row on any of its 22 pages, because every page answers an operational question rather than
reporting a headline number. Add the row when the page has a headline. Do not add it as
decoration.

## Z order: match what Desktop writes

Desktop bands z in thousands, and it puts the main content visual at `0` with chrome above it.
All 148 visuals in the live report follow this.

| Band | Holds |
| --- | --- |
| 0 | the main content visual, the point of the page |
| 1000 to 3000 | secondary content, background shapes |
| 6000 to 9000 | images and logos |
| 10000 and up | slicers and the header strip |

Use this rather than inventing a scheme. A hand authored page that numbers 0 to 399 will produce
a mixed and meaningless stack the moment Desktop touches the report and renumbers its own
visuals in thousands.

## Tab order: band it in hundreds

Every visual carries `position.tabOrder`, and leaving it at the default gives the order visuals
were added, which is almost never reading order.

| Band | Holds |
| --- | --- |
| 100 | logo or the first thing a screen reader should hit |
| 200 to 400 | header slicers, left to right |
| 500 | the main content visual |
| 600 and up | secondary content |
| 2000 and up | hidden helper visuals, so they land last |

## Parking a visual without spending canvas

`isHidden` is a top level key in `visual.json`, a sibling of `position` and `visual`, not a
property inside either.

```json
{
  "name": "vSprintFilterCarrier",
  "position": { "x": 8, "y": 8, "z": 2000, "height": 56, "width": 112, "tabOrder": 2000 },
  "visual": { "visualType": "slicer" },
  "isHidden": true
}
```

Useful for holding a filter on a page without showing the control. Give it a tab order in the
hidden band so keyboard users are not stopped on an invisible object.

## Detecting the schema version instead of hardcoding it

Every `page.json` and `visual.json` starts with a `$schema` URL carrying a version, for example
`.../visualContainer/2.11.0/schema.json`. The version changes as Desktop updates. Do not
hardcode one you saw once.

Read the versions already in the project and use the HIGHEST one present, not the first one you
open. Desktop only bumps a file's version when it re-saves that file, so a real project carries
a mix. In the live report 125 visuals sit at `2.10.0` and 23 at `2.11.0`, on the same pages.
Opening "one existing visual.json" gives a different answer depending on which you pick.

```powershell
Get-ChildItem .\*.Report\definition -Recurse -Filter visual.json |
  Select-String -Pattern '"\$schema"\s*:\s*"([^"]+)"' |
  ForEach-Object { $_.Matches[0].Groups[1].Value } |
  Sort-Object -Unique
```

If the project has no visuals yet, fall back to the version you last confirmed against a real
Desktop save, and tell the user to double check it after the first reopen.

# Layout and schema versions

Canvas sizes, a starting layout on the same 8 pixel grid used in
`design-principles.md` in the `powerbi-report-design` skill, a z order convention, and how to avoid hardcoding a schema
version.

## Canvas size

Match `powerbi-report-design`: 16 by 9, 1280 by 720 as the default. Use 1920 by 1080 only for
a report meant to fill a large screen, and 320 by 240 for a tooltip page.

## An 8 pixel grid starting layout

Margins of 24px on all sides, gaps of 16px between visuals. These are starting points, adjust
to the actual content, but keep every value a multiple of 8 so visuals line up cleanly.

**KPI row (4 cards) plus content below, on a 1280 by 720 canvas:**

| Element | x | y | width | height |
| --- | --- | --- | --- | --- |
| KPI 1 | 24 | 24 | 296 | 120 |
| KPI 2 | 336 | 24 | 296 | 120 |
| KPI 3 | 648 | 24 | 296 | 120 |
| KPI 4 | 960 | 24 | 296 | 120 |
| Content area (single large visual) | 24 | 160 | 1232 | 536 |

**2 by 2 grid instead of one large visual, same content area:**

| Element | x | y | width | height |
| --- | --- | --- | --- | --- |
| Top left | 24 | 160 | 608 | 256 |
| Top right | 648 | 160 | 608 | 256 |
| Bottom left | 24 | 432 | 608 | 256 |
| Bottom right | 648 | 432 | 608 | 256 |

This matches the house page layout preference in `powerbi-modeling`: page 1 is KPI cards plus
one Date slicer (a Year, Quarter, Month hierarchy) only, page 2 is supporting tables and trend
charts. For page 1, drop the content area and add the single Date slicer instead, sized about 150
wide by matching the KPI row height, placed to the right of the KPI cards or in a thin strip above
them.

## Z order convention

Keep it simple and consistent across pages:

- 0 to 99: decorative or background elements
- 100 to 199: header bar and slicers
- 200 to 299: KPI cards
- 300 to 399: main content visuals (charts, tables, matrices)

Assign z within a band in the order the visuals were added, for example the first KPI card is
200, the second is 201.

## Detecting the schema version instead of hardcoding it

Every `page.json` and `visual.json` starts with a `$schema` URL that includes a version
number, for example `.../visualContainer/2.0.0/schema.json`. This version changes as Power BI
Desktop updates. Do not hardcode a version you saw once.

Before writing any new file, open one existing `visual.json` already in the project (any
visual on any page) and read its `$schema` value. Use that exact value for every new
`page.json` and `visual.json` you write in this project. If the project has no visuals yet
(a brand new blank page), fall back to the version you most recently confirmed against a real
Desktop save, and flag to the user that it should be double checked after the first reopen.

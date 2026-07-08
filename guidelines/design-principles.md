# Power BI report design principles

These are the rules of thumb that keep showing up across Microsoft, SQLBI, Zebra BI and
IBCS, Data Goblins, and Storytelling with Data. They are safe defaults. They are not laws.
Read the situation. A dense operational table for one analyst is not the same as an
executive summary page, and the rules bend accordingly. The report-design skill points here
and adds the how-to detail.

## Purpose and layout

1. Five second rule. The main point of a page should be readable in about five seconds. If
   it takes longer, the page is doing too much.
2. One decision per page. Decide what question the page answers, then cut anything that does
   not serve it.
3. Three tier layout. KPIs and the headline on top, the "why" charts (trend, breakdown) in
   the middle, detail tables at the bottom. Executives read top down and stop early.
4. Follow the reading path. Most eyes go top left first, then across and down (a Z or F
   pattern). Put the most important visual top left.
5. Limit density. Roughly six to eight visuals and ten to twenty fields per page. This helps
   both readability and refresh and render performance.

## Chart selection (match the chart to the question)

6. Comparison across categories: bar or column. Trend over time: line. Variance against a
   target or prior period: bar with a reference, or a waterfall. Correlation or outliers:
   scatter. Part to whole: stacked bar, or a treemap, and only use pie or donut for a
   handful of slices.
7. Avoid pie, donut, and gauge unless it is genuinely part to whole with fewer than about
   eight categories. They are hard to read and waste space.
8. Always show a comparison. A raw number alone tells no story. Pair it with a target,
   budget, prior period, or benchmark. This is the core idea behind IBCS.
9. Prefer small multiples over many overlapping lines. A grid of small charts beats
   spaghetti.

## Color

10. Three to five purposeful colors per page. Give each a consistent meaning. Gray for
    context, one accent for the thing in focus, and reserve red and green for negative and
    positive. Never let a brand color override a semantic meaning (do not make "bad" blue
    just because blue is the brand).
11. Default to colorblind safe palettes. Okabe-Ito for categorical series, ColorBrewer
    colorblind safe sets for sequential and diverging. Test a palette in Viz Palette before
    you commit. See house-default-theme.json for the ready set.
12. Never use color as the only signal. Back it with a label, an icon, or position, so the
    message survives for a colorblind reader and in grayscale printing.

## Typography

13. Sans serif and a small font set. Segoe UI is the Power BI default for text and reads
    well. DIN is the default for numbers on charts. Keep to one or two families and a tight
    size scale. Note that custom fonts may not render on non Windows clients, so stick to
    web safe sans serif for anything that must travel.
14. Make the hierarchy obvious. Large bold KPI values, medium headings, smaller secondary
    text. Do not center long text. Left align for reading.
15. Insight driven titles. Title a visual with the takeaway, not the field name. "Revenue is
    12 percent below target" beats "Revenue by Month".

## Structure and interaction

16. Use an 8 pixel grid. Align everything, keep consistent gaps of about 8 to 10 pixels, and
    leave generous white space. Misalignment is the fastest way a report looks amateur.
17. Declutter. Drop heavy borders, background fills, redundant gridlines, and legends you do
    not need. Less non data ink means lower cognitive load (Tufte, Knaflic).
18. Slicers. Keep about five visible. Beyond that, switch to dropdowns. Sync slicers across
    pages where it helps, and always give the user a way to clear all. Match the question to
    the slicer type (list, dropdown, between for numeric ranges, relative date for dates).
19. Navigation. Use buttons plus bookmarks for an app like flow, and a back button for drill
    through. Name every object clearly in the Selection and Bookmarks panes so future you can
    maintain it.
20. Filter pane. Format it to match the report. Hide or lock filters you do not want changed.
    Decide whether it opens expanded or collapsed. Consider a single Apply button so the
    report does not re-query on every click.

## Accessibility (WCAG, and it is not optional)

21. Contrast. At least 4.5 to 1 for normal text, 3 to 1 for large text and non text elements
    like chart bars. Check a live canvas with the TPGi Colour Contrast Analyser eyedropper.
22. Alt text on every non decorative visual, and set a logical tab order in the Selection
    pane. Do not leave tab order at the default.
23. Design once as a system. Encode colors, fonts, and visual defaults in one theme JSON and
    reuse it across pages and reports. This is Kurt Buhler's atomic design idea, and it is the
    single biggest lever for a consistent, professional look. See house-default-theme.json.

## When to bend the rules

- A detail or export page for one power user can be dense and table heavy. The five second
  rule does not apply to a data extract.
- An operational monitoring wall can use more red and green than an exec deck, because alert
  state is the whole point.
- A one number scorecard can be a single big card. Not every page needs three tiers.
- IBCS is a strict standard. Adopt its ideas (always compare, consistent notation, unified
  scaling) even if you do not adopt every rule.

## Sources

See sources.md for the full list. The anchors for design are Microsoft Learn report design
and accessibility, SQLBI and Data Goblins (Kurt Buhler), Zebra BI and IBCS, Storytelling
with Data, and the Financial Times Visual Vocabulary for chart selection.

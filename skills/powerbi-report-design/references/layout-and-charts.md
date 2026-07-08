# Layout and charts

How to lay out a page and pick the right chart. The situational rules are in
`guidelines/design-principles.md`. This file is the how-to.

## Canvas and grid

- Canvas size 16:9. The common sizes are 1280x720 or 1280x800. Set it in the Format pane under
  Canvas settings. Pick one and use it for every page so the report feels consistent.
- Use an 8 pixel grid. Position and size every visual on multiples of 8, and keep consistent
  gaps of about 8 to 10 pixels. Turn on Snap to grid and use the alignment tools (Format,
  Align) to line up edges. Misalignment is the fastest way a report looks amateur.
- Leave generous white space. Empty space is not wasted, it groups related visuals and gives
  the eye somewhere to rest.
- Build a light backing structure. A few subtle background shapes or a slim header band help
  group the three tiers without heavy borders.

## The three tier layout

Executives read top down and stop early, so put the answer first.

1. Top tier: KPI cards and the headline number. The one or two numbers the page is about.
2. Middle tier: the "why" charts. Trend over time and a breakdown that explains the KPI.
3. Bottom tier: detail tables. The supporting rows for anyone who wants to dig in.

Follow the reading path. Most eyes go top left first, then across and down in a Z or F pattern.
Put the single most important visual top left.

## The five second rule and one decision per page

- Five second rule. The main point of a page should be readable in about five seconds. If it
  takes longer, the page is carrying too much.
- One decision per page. Decide the single question the page answers, then cut anything that
  does not serve it. Split a crowded page into two focused pages.
- Density limit. About six to eight visuals and ten to twenty fields per page. This helps both
  readability and render performance. A slow page is often an overloaded page.

## The house page layout preference

- Page 1 is the summary. KPI cards across the top, plus a Year slicer and a Month slicer, and
  nothing else. No detail tables on page 1. It answers "how are we doing" at a glance.
- Page 2 is the support. Trend charts and the detail tables that explain the KPIs on page 1.
- Sync the Year and Month slicers across both pages so the filter context carries over. See
  `references/slicers-and-navigation.md`.

## Choose the chart by the question

Match the chart to what the reader is asking. This mirrors the Financial Times Visual
Vocabulary, which sorts charts by intent (comparison, change over time, deviation, correlation,
part to whole, distribution).

| The question | Reach for | Notes |
| --- | --- | --- |
| Compare or rank categories | Bar (long labels) or column, sorted | Sort by value, not alphabetically. Bar handles long category names. |
| Trend over time | Line, or column for a few periods | Line for many points, column when there are only a handful. |
| Variance vs a target or prior period | Bar with a reference line, or a waterfall | Waterfall shows the bridge from a start value to an end value. |
| Correlation or outliers | Scatter | The standard way to show the relationship between two continuous measures. |
| Part to whole | Stacked bar or treemap | Pie or donut only for a small part to whole with fewer than about eight slices. |
| Many series over time | Small multiples grid | A grid of small charts beats overlapping spaghetti lines. |
| Distribution of values | Histogram, or a column with a binned axis | Shows spread and shape, not just an average. |

## Rules that keep charts honest

- Always show a comparison. A raw number alone tells no story. Pair it with a target, budget,
  prior period, or benchmark. This is the core idea behind IBCS.
- Prefer small multiples over many overlapping lines. When five or more series cross, split
  them into a grid of small charts with a shared axis.
- Avoid pie, donut, and gauge unless it is genuinely part to whole with fewer than about eight
  categories. They are hard to read and waste space. A sorted bar almost always beats a pie.
- Insight driven titles. Title a visual with the takeaway, not the field name. "Tickets closed
  fell 8 percent last month" beats "Count of Tickets by Month".
- Declutter each visual. Turn off redundant gridlines, drop the legend when the series is
  obvious, and remove borders and fills that carry no data.

## When to bend it

- A detail or export page for one power user can be dense and table heavy. The five second rule
  does not apply to a data extract.
- An operational monitoring wall can lean on red and green more than an exec deck, because
  alert state is the whole point.
- A single number scorecard can be one big card. Not every page needs three tiers.

See `guidelines/design-principles.md` for the full list and the sources behind it.

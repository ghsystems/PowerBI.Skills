# Visual types and patterns

A `visual.json` describes one visual: its type, its data bindings (query roles), and its
formatting. This reference gives the common visual type identifiers and query roles, plus a
few worked examples.

Confidence note: the two worked examples below (trend chart, slicer) are shaped directly from
a real, working report that Power BI Desktop generated, so they are safe to reuse as a
pattern. The catalog table gives the generally documented query roles for the other common
visual types. Before relying on a type you have not used before, generate one manually in
Power BI Desktop first, save, then read the `visual.json` it wrote to confirm the exact shape
for your Desktop version, and reuse the `$schema` value it used.

## Visual type catalog

| Visual | `visualType` | Main query roles |
| --- | --- | --- |
| KPI card | `cardVisual` | `Data` (the value), `ReferenceLabels` (a comparison value), `AdditionalMeasure` (a change metric) |
| Bar or column | `clusteredColumnChart`, `clusteredBarChart`, `columnChart` (stacked), `barChart` (stacked) | `Category`, `Y`, `Series` (optional legend) |
| Line | `lineChart` | `Category`, `Y`, `Y2` (optional second axis), `Series` (optional) |
| Area | `areaChart` | `Category`, `Y`, `Series` (optional) |
| Combo | `lineClusteredColumnComboChart`, `lineStackedColumnComboChart` | `Category`, `ColumnY`, `LineY`, `Series` |
| Table | `tableEx` | `Values`, one projection per column, in the column order you want |
| Matrix | `pivotTable` | `Rows`, `Columns`, `Values` |
| Slicer | `slicer` | `Values` |
| Donut or pie | `donutChart`, `pieChart` | `Category`, `Y` |
| Scatter | `scatterChart` | `Category`, `X`, `Y`, `Size` (optional) |
| Waterfall | `waterfallChart` | `Category`, `Y`, `Breakdown` (optional) |
| KPI | `kpi` | `Indicator` (the value), `TrendAxis`, `Goals` (the target) |

A field reference is always one of these two shapes:

```json
{ "Column":  { "Expression": { "SourceRef": { "Entity": "TableName" } }, "Property": "ColumnName" } }
```
```json
{ "Measure": { "Expression": { "SourceRef": { "Entity": "MeasureTableName" } }, "Property": "MeasureName" } }
```

`Entity` and `Property` are the exact table and column or measure names in the semantic
model, case sensitive. `queryRef` is conventionally `"Table.Field"`, `nativeQueryRef` is just
the field name.

## Worked example: a trend chart with a category axis and one measure

Shaped from a real working line or area chart. Genericize the table and field names to your
own model.

```json
{
  "name": "vSalesTrend",
  "position": { "x": 0, "y": 0, "z": 0, "height": 300, "width": 600, "tabOrder": 0 },
  "visual": {
    "visualType": "lineChart",
    "query": {
      "queryState": {
        "Category": {
          "projections": [
            {
              "field": {
                "Column": {
                  "Expression": { "SourceRef": { "Entity": "dim_date" } },
                  "Property": "Month"
                }
              },
              "queryRef": "dim_date.Month",
              "nativeQueryRef": "Month",
              "active": true
            }
          ]
        },
        "Y": {
          "projections": [
            {
              "field": {
                "Measure": {
                  "Expression": { "SourceRef": { "Entity": "_Measures" } },
                  "Property": "Total Sales"
                }
              },
              "queryRef": "_Measures.Total Sales",
              "nativeQueryRef": "Total Sales"
            }
          ]
        }
      },
      "sortDefinition": {
        "sort": [
          {
            "field": {
              "Column": {
                "Expression": { "SourceRef": { "Entity": "dim_date" } },
                "Property": "Month"
              }
            },
            "direction": "Ascending"
          }
        ]
      }
    }
  },
  "filterConfig": {
    "filters": [
      {
        "name": "excludeBlankCategory",
        "field": {
          "Column": {
            "Expression": { "SourceRef": { "Entity": "dim_date" } },
            "Property": "Month"
          }
        },
        "type": "Advanced",
        "filter": {
          "Version": 2,
          "From": [{ "Name": "t", "Entity": "dim_date", "Type": 0 }],
          "Where": [
            {
              "Condition": {
                "Not": {
                  "Expression": {
                    "Comparison": {
                      "ComparisonKind": 0,
                      "Left": { "Column": { "Expression": { "SourceRef": { "Source": "t" } }, "Property": "Month" } },
                      "Right": { "Literal": { "Value": "null" } }
                    }
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}
```

The `excludeBlankCategory` filter is a genuinely useful, validated pattern: it drops rows
where the category is blank, which otherwise shows up as an ugly blank bar or a broken point
at the end of a trend line. Reuse this shape whenever a category column can be null.

## Worked example: a slicer

Shaped from a real working slicer. Genericize the table and field name.

```json
{
  "name": "vRegionSlicer",
  "position": { "x": 0, "y": 0, "z": 0, "height": 300, "width": 150, "tabOrder": 1 },
  "visual": {
    "visualType": "slicer",
    "query": {
      "queryState": {
        "Values": {
          "projections": [
            {
              "field": {
                "Column": {
                  "Expression": { "SourceRef": { "Entity": "dim_region" } },
                  "Property": "Region"
                }
              },
              "queryRef": "dim_region.Region",
              "nativeQueryRef": "Region",
              "active": true
            }
          ]
        }
      }
    },
    "objects": {
      "data": [{ "properties": { "mode": { "expr": { "Literal": { "Value": "'Basic'" } } } } }],
      "selection": [
        {
          "properties": {
            "selectAllCheckboxEnabled": { "expr": { "Literal": { "Value": "true" } } },
            "singleSelect": { "expr": { "Literal": { "Value": "false" } } }
          }
        }
      ]
    },
    "visualContainerObjects": {
      "title": [{ "properties": { "show": { "expr": { "Literal": { "Value": "false" } } } } }]
    }
  },
  "filterConfig": {
    "filters": [
      {
        "name": "regionCategorical",
        "field": {
          "Column": {
            "Expression": { "SourceRef": { "Entity": "dim_region" } },
            "Property": "Region"
          }
        },
        "type": "Categorical",
        "objects": {
          "general": [
            { "properties": { "isInvertedSelectionMode": { "expr": { "Literal": { "Value": "true" } } } } }
          ]
        }
      }
    ]
  }
}
```

`"mode": "'Basic'"` gives a checkbox list slicer, which is the safest default. Use
`isInvertedSelectionMode` on the `Categorical` filter, it is how a slicer represents "nothing
excluded yet" internally, this is the real internal shape Desktop writes, keep it as shown.

## KPI card, confirmed shape

Confirmed against a real Desktop generated card at visualContainer schema 2.10.0 in a live
ABC Company report. The `Data` role carries the measure, and `displayName` on the projection
is the label text the card shows next to the value.

```json
"visual": {
  "visualType": "cardVisual",
  "query": {
    "queryState": {
      "Data": {
        "projections": [{
          "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "_Measures" } }, "Property": "KPI Critical Label" } },
          "queryRef": "_Measures.KPI Critical Label",
          "nativeQueryRef": "KPI Critical Label",
          "displayName": "Critical Vulnerabilities"
        }]
      }
    }
  },
  "objects": {
    "value": [{
      "properties": {
        "fontSize": { "expr": { "Literal": { "Value": "10D" } } },
        "horizontalAlignment": { "expr": { "Literal": { "Value": "'left'" } } },
        "textWrap": { "expr": { "Literal": { "Value": "true" } } },
        "fontColor": { "solid": { "color": { "expr": { "Measure": { "Expression": { "SourceRef": { "Entity": "_Measures" } }, "Property": "KPI Critical Color" } } } } }
      },
      "selector": { "id": "default" }
    }],
    "label": [{
      "properties": {
        "position": { "expr": { "Literal": { "Value": "'aboveValue'" } } },
        "fontSize": { "expr": { "Literal": { "Value": "9D" } } }
      },
      "selector": { "id": "default" }
    }]
  }
}
```

What the live confirmation established:

- Entries under `objects.value` and `objects.label` each need `"selector": { "id": "default" }`.
- The value `fontColor` accepts a `Measure` expression, so a field value color measure (a Text
  measure returning a hex) drives the card font color. This is how the semantic good and bad
  color reaches the card without a hardcoded hex in the report layer.
- Watch overflow. A preformatted label string like `439 v -35 vs last month` clips at 13pt
  inside a 200 by 112 card. 10pt plus `textWrap: true` fits with room to spare.
- `ReferenceLabels` (a comparison value) and `AdditionalMeasure` (a change metric) remain the
  documented extra roles for when the comparison is not baked into the measure string.

Drive any conditional color on the card from a model measure that returns a hex string built
from the house theme's semantic colors, for example `IF ( [YoY %] >= 0, "#009E73", "#D55E00" )`
using the `good` and `bad` values from `guidelines/house-default-theme.json`, rather than a
one off color choice.

This `cardVisual` is the new card (general availability November 2025), which replaces the old
Card and Multi-row card. It carries reference labels in the visual and can hold multiple cards at
once, which the house KPI card uses to show a value with its delta versus the prior month.

## Matrix, sparklines, conditional formatting, and the analytical visuals

The report-design skill covers the design side of these. A few notes for authoring them in PBIR:

- Matrix (`pivotTable`) uses `Rows`, `Columns`, `Values`. Its stepped layout, subtotals, and grand
  totals are formatting objects on the visual, not query roles. Exact column widths are stored per
  column as a `columnWidth` value. The reliable way to set them is to drag once in Desktop, save,
  then read the written value back.
- Native sparklines live inside a table or matrix as an extra measure projection with a sparkline
  formatting object. They are capped at 5 per visual and 52 points, and they limit a matrix to 25
  columns. See the report-design `references/tables-and-matrix.md`.
- Conditional formatting is applied per visual, a theme cannot store the rules. Drive a semantic
  color from a model measure that returns a hex string or a CSS color name (a theme slot name like
  `"good"` will not resolve here), then bind it as the field value. See the report-design
  `references/conditional-formatting.md`,
  and note it is opt-in, do not add it unless the user asked.
- Native small multiples is a `Small multiples` projection role on a cartesian chart (bar, column,
  line, area), not a separate visual type.
- The AI visuals, decomposition tree and key influencers, are Pro safe, their AI runs in the
  engine, not Copilot. Their internal `visualType` and query role names are less documented and
  less stable than the core charts, so generate one in Desktop, save, and read its `visual.json`
  before authoring it in code. See the report-design `references/analytical-visuals.md`.

## Dynamic titles, bind a title to a measure

A visual title does not have to be static text. Bind the title `text` to a measure that returns a
string, and the title states the number in context and updates as the slicers change. This is how
the insight driven titles the report-design skill asks for become live instead of frozen.

Write the measure to return a string, and make it blank safe so it falls back to a plain label when
there is no data in context:

```
Title Effort vs Estimate =
VAR r = [Effort Ratio]
RETURN
IF (
    ISBLANK ( r ) || r = 0,
    "Actual vs estimated effort",
    "Actual effort is " & FORMAT ( r, "0%" ) & " of the estimate"
)
```

In the `visual.json`, set the title `text` to a measure reference instead of a literal. Only the
`text` property changes, the rest of the title formatting stays as it was:

```json
"visualContainerObjects": {
  "title": [
    {
      "properties": {
        "show": { "expr": { "Literal": { "Value": "true" } } },
        "text": {
          "expr": {
            "Measure": {
              "Expression": { "SourceRef": { "Entity": "_Measures" } },
              "Property": "Title Effort vs Estimate"
            }
          }
        }
      }
    }
  ]
}
```

The `Entity` and `Property` are the exact measure table and measure name, case sensitive, the same
field reference shape used everywhere else in PBIR.

### The grain trap, read this before you ship one

A title is one string for the whole visual, so the title measure is evaluated at the visual total
grain, not per category. That is fine for a measure that sums cleanly, like effort over estimate,
where the total is a correct weighted ratio. It breaks for a per row ratio measure.

The classic failure is a measure written as `DIVIDE ( SUM ( effort ), AVERAGE ( capacity ) )`. That
is correct per person, but at the all people level it reads the sum of everyone's effort over one
average capacity, so the title shows a number roughly the head count times too high. A ratio that
should sit near 90 percent can render as over 1800 percent.

Fix it by aggregating at the right grain inside the title measure:

- If the ratio sums cleanly, use the weighted total, `DIVIDE ( SUM ( num ), SUM ( den ) )`.
- If the ratio is per row and does not sum, average the per row values with `AVERAGEX` over the
  entity, for example `AVERAGEX ( VALUES ( dim_owner[Owner] ), [Per Person Ratio] )`.

The same grain trap applies to any measure shown as a single number, a card as much as a title.

## Slicer sync groups

The report-design skill covers syncing slicers across pages in Desktop. In PBIR that sync is stored
on each slicer as a `syncGroup`. Slicers that share a group name and have field and filter changes
turned on move together.

```json
"syncGroup": {
  "groupName": "Company",
  "fieldChanges": true,
  "filterChanges": true
}
```

Put `syncGroup` at the `visual` level, next to `visualType`. Group by the exact field, so a Company
slicer on one fact does not drive a Company slicer built on a different table. Leave search box
slicers (a `selfFilter` slicer) out of any group, they are usually page specific.

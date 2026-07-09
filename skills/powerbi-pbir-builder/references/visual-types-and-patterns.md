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

## KPI card, typical shape

The general documented pattern (confirm the exact property names against a real
Desktop-generated card in your project before shipping this to a client):

```json
"visual": {
  "visualType": "cardVisual",
  "query": {
    "queryState": {
      "Data": {
        "projections": [{
          "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "_Measures" } }, "Property": "Total Sales" } },
          "queryRef": "_Measures.Total Sales",
          "nativeQueryRef": "Total Sales"
        }]
      },
      "ReferenceLabels": {
        "projections": [{
          "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "_Measures" } }, "Property": "Total Sales PY" } },
          "queryRef": "_Measures.Total Sales PY",
          "nativeQueryRef": "Total Sales PY"
        }]
      }
    }
  }
}
```

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

# Visual types and data binding

A `visual.json` describes one visual: its type, its data bindings (query roles), and its
formatting. This file covers the type catalog and how to bind fields to it. Formatting and the
selector grammar are in `references/formatting-and-selectors.md`. Cards and measure bound titles
are in `references/cards-and-dynamic-text.md`. Filters and slicer sync are in
`references/filters-and-sync.md`.

Confidence note: the worked examples below are shaped from a real, working report that Power BI
Desktop generated, so they are safe to reuse as a pattern. The catalog table gives the generally
documented query roles for the other types. Before relying on a type you have not used before,
generate one manually in Desktop first, save, then read the `visual.json` it wrote to confirm
the exact shape for your Desktop version, and reuse the `$schema` value it used.

## Visual type catalog

| Visual | `visualType` | Main query roles |
| --- | --- | --- |
| Card, new | `cardVisual` | `Data` (the value), `ReferenceLabels` (a comparison), `AdditionalMeasure` (a change metric) |
| Card, legacy | `card` | `Values`. Still the right tool for a thin inline value strip, where `cardVisual` cannot go small |
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
| KPI | `kpi` | `Indicator`, `TrendAxis`, `Goals` (the target) |
| Image | `image` | none, the source is a formatting object, see below |

Two roles exist on most cartesian visuals and are easy to miss:

- `Tooltips` takes extra measure projections that appear on hover without occupying the chart.
  Useful for putting a readable date on a chart whose axis shows a code.
- `Small multiples` is a projection role on a cartesian chart, not a separate visual type.

## Field references

A field reference is always one of these two shapes:

```json
{ "Column":  { "Expression": { "SourceRef": { "Entity": "TableName" } }, "Property": "ColumnName" } }
```
```json
{ "Measure": { "Expression": { "SourceRef": { "Entity": "MeasureTableName" } }, "Property": "MeasureName" } }
```

`Entity` and `Property` are the exact table and column or measure names in the semantic model,
case sensitive. `queryRef` is conventionally `"Table.Field"`, `nativeQueryRef` is just the field
name. Check the TMDL if unsure. A mismatch here parses fine and renders an empty visual.

## Letting the user choose the field

A field parameter table in the model can drive a role, so one slicer re-cuts the chart. The
`fieldParameters` block is a sibling of `projections` inside the role.

```json
"Series": {
  "projections": [
    { "field": { "Column": { "Expression": { "SourceRef": { "Entity": "dim_activity" } }, "Property": "Activity" } },
      "queryRef": "dim_activity.Activity", "nativeQueryRef": "Activity", "displayName": "Activity" }
  ],
  "fieldParameters": [
    { "parameterExpr": { "Column": {
        "Expression": { "SourceRef": { "Entity": "Parameter - fact_effort" } },
        "Property": "Legend - Actual vs Estimated Efforts (Hour)" } },
      "index": 0, "length": 1 }
  ]
}
```

`index` is where in the role the swappable field sits and `length` is how many slots it
occupies. The `projections` entry is the currently selected field, so it still has to be a real
field. For the field parameter table's TMDL, see the `powerbi-dax` skill.

## Worked example: a trend chart

Shaped from a real working line or area chart. Genericize the table and field names.

```json
{
  "name": "vSalesTrend",
  "position": { "x": 8, "y": 80, "z": 0, "height": 312, "width": 1264, "tabOrder": 500 },
  "visual": {
    "visualType": "lineChart",
    "query": {
      "queryState": {
        "Category": {
          "projections": [
            {
              "field": { "Column": { "Expression": { "SourceRef": { "Entity": "dim_date" } }, "Property": "Month" } },
              "queryRef": "dim_date.Month",
              "nativeQueryRef": "Month",
              "active": true
            }
          ]
        },
        "Y": {
          "projections": [
            {
              "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "_Measures" } }, "Property": "Total Sales" } },
              "queryRef": "_Measures.Total Sales",
              "nativeQueryRef": "Total Sales"
            }
          ]
        },
        "Tooltips": {
          "projections": [
            {
              "field": { "Measure": { "Expression": { "SourceRef": { "Entity": "_Measures" } }, "Property": "Sales YoY %" } },
              "queryRef": "_Measures.Sales YoY %",
              "nativeQueryRef": "Sales YoY %"
            }
          ]
        }
      },
      "sortDefinition": {
        "sort": [
          {
            "field": { "Column": { "Expression": { "SourceRef": { "Entity": "dim_date" } }, "Property": "Month" } },
            "direction": "Ascending"
          }
        ]
      }
    }
  },
  "drillFilterOtherVisuals": true
}
```

`drillFilterOtherVisuals` sits at the `visual` level and is `true` on essentially every visual
Desktop writes. Include it.

## Worked example: a slicer

```json
{
  "name": "vRegionSlicer",
  "position": { "x": 8, "y": 8, "z": 10000, "height": 56, "width": 128, "tabOrder": 200 },
  "visual": {
    "visualType": "slicer",
    "query": {
      "queryState": {
        "Values": {
          "projections": [
            {
              "field": { "Column": { "Expression": { "SourceRef": { "Entity": "dim_region" } }, "Property": "Region" } },
              "queryRef": "dim_region.Region",
              "nativeQueryRef": "Region",
              "active": true
            }
          ]
        }
      }
    },
    "objects": {
      "data": [{ "properties": { "mode": { "expr": { "Literal": { "Value": "'Dropdown'" } } } } }],
      "general": [{ "properties": {
        "orientation":       { "expr": { "Literal": { "Value": "1D" } } },
        "selfFilterEnabled": { "expr": { "Literal": { "Value": "true" } } }
      } }],
      "selection": [{ "properties": {
        "selectAllCheckboxEnabled": { "expr": { "Literal": { "Value": "true" } } },
        "singleSelect":             { "expr": { "Literal": { "Value": "false" } } }
      } }],
      "header": [{ "properties": { "text": { "expr": { "Literal": { "Value": "'Region'" } } } } }]
    },
    "visualContainerObjects": {
      "title": [{ "properties": { "show": { "expr": { "Literal": { "Value": "false" } } } } }]
    }
  }
}
```

Slicer specifics worth knowing:

- `mode` is `'Dropdown'` or `'Basic'`. Dropdown is the right default in a header strip, because
  it holds its height whatever the list length. Basic is the checkbox list.
- `orientation` is `1D` for horizontal and `0D` for vertical.
- `selfFilterEnabled` turns on the search box. Add it once a dimension passes roughly 30 members.
- Turn the container `title` off and set the slicer's own `header.text` instead. The label then
  sits inside the control, which is how a 56 pixel tall slicer still says what it filters.

## The image visual

Not a data visual. The source is a formatting object pointing at a registered resource.

```json
"visual": {
  "visualType": "image",
  "objects": { "image": [{ "properties": { "sourceFile": { "image": {
    "name": { "expr": { "Literal": { "Value": "'logo.png'" } } },
    "url":  { "expr": { "ResourcePackageItem": {
                "PackageName": "RegisteredResources", "PackageType": 1,
                "ItemName": "logo12345.png" } } },
    "scaling": { "expr": { "Literal": { "Value": "'Normal'" } } }
  } } } }] }
}
```

The `ItemName` must match an entry in `definition/report.json` under `resourcePackages`, in the
`RegisteredResources` package, with `"type": "Image"`. Desktop writes that entry when you insert
the image, so insert it once in Desktop rather than hand registering the asset. Turn the
container border off so a logo has no box around it.

## Matrix, table, and the analytical visuals

- Matrix (`pivotTable`) uses `Rows`, `Columns`, `Values`. Its layout, subtotals, and grand totals
  are formatting objects, not query roles.
- Native sparklines live inside a table or matrix as an extra measure projection with a sparkline
  formatting object. They are capped at 5 per visual and 52 points, and they limit a matrix to 25
  columns.
- The AI visuals, decomposition tree and key influencers, are Pro safe, their intelligence runs
  in the engine rather than in Copilot. Their internal type and role names are less documented
  and less stable than the core charts, so generate one in Desktop, save, and read its
  `visual.json` before authoring one in code.

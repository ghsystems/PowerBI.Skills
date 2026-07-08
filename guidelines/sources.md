# Sources

Curated, deduped, and checked against a Power BI Pro lens. Everything here is free to read.
Where a source is mostly about Fabric or Premium features, it is flagged. Verified active as
of mid 2026. Re-check yearly.

## Must-read anchors

- Understand star schema and the importance for Power BI (Microsoft): https://learn.microsoft.com/en-us/power-bi/guidance/star-schema
- The importance of star schemas in Power BI (SQLBI): https://www.sqlbi.com/articles/the-importance-of-star-schemas-in-power-bi/
- DAX Guide, function reference with a version compatibility matrix (SQLBI): https://dax.guide/
- Query folding guidance in Power BI Desktop (Microsoft): https://learn.microsoft.com/en-us/power-bi/guidance/power-query-folding
- Why does Power BI query my data source more than once (Chris Webb): https://blog.crossjoin.co.uk/2019/10/13/why-does-power-bi-query-my-data-source-more-than-once/
- Design effective reports and accessibility (Microsoft): https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-tips-and-tricks-for-creating-reports and https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-accessibility-overview

## Modeling and star schema

- MS Learn, model relationships: https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-relationships-understand
- MS Learn, many to many relationship guidance: https://learn.microsoft.com/en-us/power-bi/guidance/relationships-many-to-many
- SQLBI, star schema or single table: https://www.sqlbi.com/articles/power-bi-star-schema-or-single-table/
- Kimball Group, dimensional modeling techniques (vendor neutral theory): https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/

## DAX

- DAX Patterns, second edition, free online (SQLBI): https://www.daxpatterns.com/
- SQLBI DAX topic hub, includes calculated columns vs measures and context transition: https://www.sqlbi.com/topics/dax/
- MS Learn DAX function reference: https://learn.microsoft.com/en-us/dax/dax-function-reference

## M, Power Query, and refresh performance

- Chris Webb's blog (Crossjoin), the deepest M and refresh performance blog: https://blog.crossjoin.co.uk/
- Chris Webb, basic query folding on a web service (pattern for non folding REST): https://blog.crossjoin.co.uk/2018/11/21/query-folding-web-service-power-bi/
- MS Learn, referencing Power Query queries (referenced steps re-execute, no free cache): https://learn.microsoft.com/en-us/power-bi/guidance/power-query-referenced-queries
- MS Learn, best practices when working with Power Query: https://learn.microsoft.com/en-us/power-query/best-practices
- MS Learn, understanding query evaluation and query folding: https://learn.microsoft.com/en-us/power-query/query-folding-basics

## Licensing and limits

- MS Learn, data refresh in Power BI (the 8 per day, 1 GB, 2 hour Pro limits): https://learn.microsoft.com/en-us/power-bi/connect-data/refresh-data
- MS Learn, configure incremental refresh and real time data: https://learn.microsoft.com/en-us/power-bi/connect-data/incremental-refresh-overview
- MS Learn, dataflows considerations and limitations, Gen1 legacy: https://learn.microsoft.com/en-us/power-bi/transform-model/dataflows/dataflows-features-limitations
- MS Learn, differences between Dataflow Gen1 and Gen2 (Gen2 needs Fabric or Premium): https://learn.microsoft.com/en-us/fabric/data-factory/dataflows-gen2-overview

## Report design and visualization

- MS Learn, create custom report themes and the theme JSON structure: https://learn.microsoft.com/en-us/power-bi/create-reports/report-themes-create-custom
- MS Learn, visualizations overview and slicers and navigators: https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualizations-overview
- SQLBI, Kurt Buhler articles, atomic design and re-using visual formatting: https://www.sqlbi.com/author/kurtbuhler/
- Data Goblins (Kurt Buhler), Dashboard Checklist and how-tos: https://data-goblins.com/power-bi
- Zebra BI, dashboard design best practices, and IBCS (guidance free, Zebra visual is a paid add-in): https://zebrabi.com/power-bi-dashboard-design-mistakes/ and https://www.ibcs.com/
- Storytelling with Data (Cole Nussbaumer Knaflic): https://www.storytellingwithdata.com/
- Financial Times Visual Vocabulary, chart selection by intent: https://github.com/Financial-Times/chart-doctor/tree/main/visual-vocabulary

## Color and accessibility

- Okabe-Ito colorblind safe categorical palette: https://siegal.bio.nyu.edu/color-palette/
- ColorBrewer 2.0, sequential and diverging with a colorblind safe filter: https://colorbrewer2.org/
- Viz Palette, test a palette for color vision deficiency: https://projects.susielu.com/viz-palette
- WebAIM contrast checker: https://webaim.org/resources/contrastchecker/
- TPGi Colour Contrast Analyser, desktop eyedropper for a live canvas: https://www.tpgi.com/color-contrast-checker/
- Theme generators, all free: PowerBI.tips (https://themes.powerbi.tips/), BIBB (https://bibb.pro/apps/theme-generator/)

## Free, Pro friendly external tools

- Tabular Editor 2, free and open source, model and TMDL editing plus Best Practice Analyzer: https://tabulareditor.com/
- DAX Studio, free, DAX authoring, server timings, and VertiPaq Analyzer for model size: https://daxstudio.org/
- Bravo for Power BI (SQLBI), free, model size, format DAX, generate a Date table: https://bravo.bi/
- Measure Killer, free single file tier, find and remove unused measures and columns: https://measurekiller.com/
- Note: all of these edit your LOCAL pbip or pbix. Writing to a PUBLISHED dataset needs the
  XMLA write endpoint, which is Premium, not Pro.

## PBIP and TMDL

- MS Learn, Power BI Desktop projects (pbip) overview: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview
- MS Learn, semantic model folder and TMDL: https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-dataset

## Maintained GitHub repos

- microsoft/powerbi-desktop-samples, monthly sample pbix files and the official report theme
  JSON schema for validation: https://github.com/microsoft/powerbi-desktop-samples
- microsoft/Analysis-Services, the Best Practice Rules JSON used by Tabular Editor's analyzer:
  https://github.com/microsoft/Analysis-Services/tree/master/BestPracticeRules
- deldersveld/PowerBI-ThemeTemplates, per visual theme JSON snippets (validate against the
  official schema, some are dated): https://github.com/deldersveld/PowerBI-ThemeTemplates
- NajiElKotob/Awesome-Power-BI, curated link directory (includes Fabric links, filter for Pro):
  https://github.com/NajiElKotob/Awesome-Power-BI

# trend.chl

Chlorophyll-a reduced to mergeable sufficient statistics on S2 level-5
cells, in log10 space: one Parquet file per 5-day composite of
`(cell, n, sumw, sumwx, sumwx2)` where x = log10(chl-a, mg m-3), so cell
means are geometric means. The third deployment of
[grist](https://github.com/hypertidy/grist), after
[trend.sst](https://github.com/mdsumner/trend.sst) and
[trend.sla](https://github.com/mdsumner/trend.sla); this repository holds
only the product knowledge (catalog, schedule, bucket, checks).

## Source

ESA Ocean Colour CCI v6.0, merged multi-sensor L3S, 5-day composites,
4 km geographic grid (8640 x 4320, 1/24 deg), from 1997-09-03. COGs
(ZSTD, 512 x 512 blocks, NaN nodata, chl-a not log-transformed) on Pawsey
Acacia at `aad-derived/esacci-oc/v6.0-release/geographic/5day/chlor_a/`,
read anonymously over https. Each COG records the THREDDS file it came
from (`SOURCE_URL`, `SOURCE_SHA256`).

The product also carries per-pixel `chlor_a_log10_bias` and
`chlor_a_log10_rmsd`. Not used yet: the RMSD is a candidate for
inverse-variance weights (a second set of sums), the bias a scientific
choice to make deliberately.

## Steps (Setonix, from the repo root, through the queue)

    sbatch onboard-chl.sh    # 24 CPUs, 96 GB: catalog, mapping, oracle

which runs, in order (each also runnable alone inside an allocation):

    build_catalog.sh   chlfiles.parquet: (date, dsn), one row per composite
    setup.sh           registry (from trend.sst) and the 8640x4320 mapping
    oracle.sh          one composite: exact totals check + map; LOOK at it

Only after the oracle passes:

    sbatch backfill-chl.sh   # 24 CPUs, 96 GB: backfill all composites, publish

publishes to `pawsey1197:aad-derived/trend-chl/` (public read:
`https://projects.pawsey.org.au/aad-derived/trend-chl/manifest.json`).

## Onboarding record

- Catalog (2026-11-05): 2127 composites, 1997-09-03 .. 2026-09-18; steps
  of 5 days throughout (continuous across year ends) except one of 7 and
  one of 10 (1997-10-13 absent).
- Oracle 2010-05-01: global totals of the cell sums equal numpy on the
  same file exactly (n = 12183690, sumw = 10485678.385498,
  sumwx = -8950079.897111); global geometric mean 10^-0.854 = 0.14 mg m-3.

## Notes

- The transform is `stat_source(transform = "log10")` (grist >= 3a61eac).
  Zero or negative pixels become non-finite and are dropped like NA.
- Polar winter leaves whole months empty at high latitudes: expected
  gaps, not failures.

## Acknowledgments

Data: ESA Ocean Colour Climate Change Initiative, Version 6.0
(https://climate.esa.int/en/projects/ocean-colour/). This work uses
resources of the Pawsey Supercomputing Research Centre, with funding from
the Australian Government and the Government of Western Australia.

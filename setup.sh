#!/bin/bash
## one-off: registry (shared with trend.sst) and the pixel -> cell mapping
## for the 8640 x 4320 grid, 512-row bands to match the COG blocks.
##   bash setup.sh      (interactive node is fine; ~10-20 min for the mapping)
set -eu
cd "$(dirname "$0")"; source ./config.sh
[ -f s2_registry.parquet ] || cp ../trend.sst/s2_registry.parquet .
$RUN Rscript - <<'R'
library(arrow); library(grist)
reg <- read_parquet("s2_registry.parquet")
files <- read_parquet("chlfiles.parquet")
src <- stat_source(Sys.getenv("SRC"), files, transform = "log10")
print(src$grid)
build_mapping(src, reg, band_rows = 512L)
R

#!/bin/bash
## onboarding oracle: one composite, two checks.
## (1) exact: the global totals of the cell sums (n, sumw, sumwx) must
##     equal the same totals computed straight from the file with numpy,
##     cos(lat) weights, log10 of positive finite pixels. Equality to
##     ~1e-9 relative tests the mapping, the band rows and the transform.
## (2) look: the map. Composite nearest 2010-05-01: expect the North
##     Atlantic spring bloom and coastal upwelling high, the subtropical
##     gyres low (about -1.5 to -1.0 in log10 mg m-3), no flips.
set -eu
cd "${SLURM_SUBMIT_DIR:-$(dirname "$0")}"; source ./config.sh
$RUN Rscript - <<'R'
library(arrow); library(grist)
reg <- read_parquet("s2_registry.parquet")
files <- read_parquet("chlfiles.parquet")
src <- stat_source(Sys.getenv("SRC"), files, transform = "log10")
i <- which.min(abs(as.Date(files$date) - as.Date("2010-05-01")))
d <- as.Date(files$date[i])
out <- accumulate_date(files$dsn[i], d, src, reg, out_path = "oracle-sums")
s <- read_parquet(out)
cat(sprintf("ORACLE %s %s\n", d, files$dsn[i]))
cat(sprintf("GRIST n=%.0f sumw=%.6f sumwx=%.6f\n", sum(s$n), sum(s$sumw), sum(s$sumwx)))
s$mean <- s$sumwx / s$sumw
ii <- match(s$cell, reg$cell)
png(sprintf("oracle-%s.png", d), 1400, 700)
pal <- hcl.colors(99, "viridis")
cl <- pal[cut(pmax(-2, pmin(1.5, s$mean)), seq(-2, 1.5, length.out = 100), labels = FALSE)]
plot(reg$lon[ii], reg$lat[ii], col = cl, pch = 15, cex = .6, asp = 1,
     main = sprintf("%s %s: log10 chl-a, expect N Atlantic bloom, low gyres", Sys.getenv("SRC"), d))
dev.off()
writeLines(c(format(d), files$dsn[i]), "oracle-date.txt")
R
DSN=$(sed -n 2p oracle-date.txt)
$RUN python3 - "$DSN" <<'PY'
import sys, numpy as np
from osgeo import gdal
gdal.UseExceptions()
ds = gdal.Open(sys.argv[1]); gt = ds.GetGeoTransform()
v = ds.GetRasterBand(1).ReadAsArray().astype(np.float64)
lat = gt[3] + (np.arange(ds.RasterYSize) + 0.5) * gt[5]
w = np.cos(np.radians(lat))[:, None] * np.ones((1, ds.RasterXSize))
with np.errstate(divide="ignore", invalid="ignore"):
    x = np.log10(v)
ok = np.isfinite(x)
print("NUMPY n=%.0f sumw=%.6f sumwx=%.6f" % (ok.sum(), w[ok].sum(), (w[ok] * x[ok]).sum()))
PY
rm -rf oracle-sums

#!/bin/bash
## does the container do everything trend.chl needs? Run on a login node:
##   bash tools/check_container.sh
## or with another RUN line, e.g. the one that clears LD_LIBRARY_PATH:
##   RUN="singularity exec --env LD_LIBRARY_PATH= $MYSOFTWARE/sif_lib/gdal-r-python-extras_latest.sif" bash tools/check_container.sh
## Each line prints OK or FAIL; paste the lot back.
cd "$(dirname "$0")/.."; source ./config.sh
echo "RUN=$RUN"
t() { local lab=$1; shift; if out=$("$@" 2>&1); then echo "OK   $lab: $(echo "$out" | tail -1)"; else echo "FAIL $lab: $(echo "$out" | tail -3 | tr '\n' ' ')"; fi; }
F=/vsicurl/$PUBLIC/1997/ESACCI-OC-L3S-CHLOR_A-MERGED-5D_DAILY_4km_GEO_PML_OCx-19970903-fv6.0_chlor_a.tif
t "singularity"      $RUN true
t "R"                $RUN Rscript -e 'cat(R.version.string)'
t "R_LIBS_USER"      $RUN Rscript -e 'cat(.libPaths()[1])'
t "arrow then grist" $RUN Rscript -e 'library(arrow); library(grist); cat("grist", format(packageVersion("grist")))'
t "grist log10"      $RUN Rscript -e 'library(grist); stopifnot("log10" %in% names(grist_transforms)); cat("transform present")'
t "vapour read"      $RUN Rscript -e "x <- vapour::vapour_raster_info('$F'); cat(x\$dimension)"
t "python gdal+numpy" $RUN python3 -c "from osgeo import gdal; import numpy; gdal.UseExceptions(); d=gdal.Open('$F'); print(gdal.__version__, numpy.__version__, d.RasterXSize, d.RasterYSize)"

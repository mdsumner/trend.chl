#!/bin/bash --login
#SBATCH --job-name=chl-site
#SBATCH --account=pawsey1362
#SBATCH --partition=work
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=8 --mem=32G --time=01:00:00
#SBATCH --output=%x-%j.out
## regenerate docs/data from the local sums (repo root is the cache
## layout: sums/, s2_registry.parquet, chlfiles.parquet), restricted to
## ocean cells via trend.sst's committed OISST cell export. Then commit
## and push docs/data with your usual credentials:
##   sbatch data-raw/export_site.sh
##   git add docs/data && git commit -m "site data" && git push
set -eu
cd "${SLURM_SUBMIT_DIR:-$PWD}"
source ./config.sh
OCEAN_JSON=${OCEAN_JSON:-../trend.sst/docs/data/cells-oisst.json}
[ -f "$OCEAN_JSON" ] || { echo "no $OCEAN_JSON: clone trend.sst beside this repo" >&2; exit 1; }
$RUN Rscript data-raw/export_site.R . docs/data "$OCEAN_JSON" || { echo "export FAILED" >&2; exit 1; }
## modes page: EOFs of the monthly export. Cells with any empty month
## (polar winter) are left out by eof.py, so this is the ice-free ocean.
$RUN python3 data-raw/eof.py docs/data occci-log10chl log10 6 || echo "WARNING: eof.py FAILED" >&2

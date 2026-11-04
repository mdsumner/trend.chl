#!/bin/bash
## weekly check of trend.chl (run by scrontab.txt): v6.0 is a fixed
## release, so most weeks the catalog is unchanged and the backfill has
## nothing to do; when the Acacia mirror gains composites (an extension
## or a new version), they are summed, published and the site follows.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
export SLURM_SUBMIT_DIR="$PWD"
echo "trend.chl weekly: $(date -u +%FT%TZ) in $PWD"
status=0
bash backfill-chl.sh         || { echo "backfill FAILED" >&2; status=1; }
bash data-raw/export_site.sh || { echo "site export FAILED" >&2; status=1; }
bash tools/publish_site.sh   || { echo "site push FAILED" >&2; status=1; }
echo "trend.chl weekly: done $(date -u +%FT%TZ), status $status"
exit $status

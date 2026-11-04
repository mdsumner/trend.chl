## shared settings, sourced by every script
SRC=occci-log10chl                       # grist source name (log10 sums)
PREFIX=esacci-oc/v6.0-release/geographic/5day/chlor_a
REMOTE=pawsey1197:aad-derived/$PREFIX    # rclone, for listing
PUBLIC=https://projects.pawsey.org.au/aad-derived/$PREFIX   # anonymous read
BUCKET=pawsey1197:aad-derived/trend-chl  # where the sums are published
module load singularity/4.1.0-slurm 2>/dev/null || true
export RUN=${RUN:-"singularity exec $MYSOFTWARE/sif_lib/gdal-r-python-extras_2026-10-25.sif"}
export R_LIBS_USER=${R_LIBS_USER:-$MYSOFTWARE/r-lib}
## per-worker GDAL limits (lessons from trend.sla)
export GDAL_CACHEMAX=256
export GDAL_PAM_ENABLED=NO
export SRC PREFIX PUBLIC

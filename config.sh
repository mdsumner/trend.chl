## shared settings, sourced by every script
SRC=occci-log10chl                       # grist source name (log10 sums)
PREFIX=esacci-oc/v6.0-release/geographic/5day/chlor_a
REMOTE=pawsey1197:aad-derived/$PREFIX    # rclone, for listing
PUBLIC=https://projects.pawsey.org.au/aad-derived/$PREFIX   # anonymous read
BUCKET=pawsey1197:aad-derived/trend-chl  # where the sums are published
## Setonix modules: singularity/4.1.0-slurm needs pawseyenv/2024.05 (the
## default pawseyenv moved on), and a non-login shell needs Lmod first
if ! type module >/dev/null 2>&1; then _u=${-//[^u]/}; set +u; source /etc/profile; [ -n "$_u" ] && set -u; fi
module load pawseyenv/2024.05 singularity/4.1.0-slurm
command -v singularity >/dev/null || { echo "singularity not found after module load" >&2; exit 1; }
export RUN=${RUN:-"singularity exec $MYSOFTWARE/sif_lib/gdal-r-python-extras_2026-10-25.sif"}
export R_LIBS_USER=${R_LIBS_USER:-$MYSOFTWARE/r-lib}
## per-worker GDAL limits (lessons from trend.sla)
export GDAL_CACHEMAX=256
export GDAL_PAM_ENABLED=NO
export SRC PREFIX PUBLIC

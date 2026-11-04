#!/bin/bash --login
#SBATCH --job-name=chl-onboard
#SBATCH --account=pawsey1362
#SBATCH --partition=work
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=24 --mem=96G
#SBATCH --time=02:00:00
#SBATCH --output=%x-%j.out
## onboarding in one job, submitted from the repo root:
##   sbatch onboard-chl.sh
## catalog -> mapping (skipped if mapping/ already exists) -> oracle.
## Then read the GRIST and NUMPY lines in chl-onboard-<jobid>.out and
## LOOK at oracle-<date>.png before any backfill.
set -eu
cd "${SLURM_SUBMIT_DIR:-$PWD}"
export SLURM_SUBMIT_DIR="$PWD"
bash build_catalog.sh
source ./config.sh
[ -f "mapping/$SRC/meta.rds" ] || bash setup.sh
bash oracle.sh

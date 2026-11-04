#!/bin/bash
## catalog: one row per 5-day composite, (date, dsn), dated by its first
## day, read anonymously from the Acacia copy. Writes chlfiles.parquet.
set -eu
cd "${SLURM_SUBMIT_DIR:-$(dirname "$0")}"; source ./config.sh
module load rclone/1.68.1
command -v rclone >/dev/null || { echo "rclone not found after module load" >&2; exit 1; }
rclone lsf -R --files-only "$REMOTE/" > chl_listing.txt
$RUN Rscript - <<'R'
x <- readLines("chl_listing.txt")
x <- x[grepl("\\.tif$", x)]
d <- as.Date(sub(".*-([0-9]{8})-fv6\\.0_chlor_a\\.tif$", "\\1", x), "%Y%m%d")
stopifnot(!anyNA(d), !anyDuplicated(d))
files <- data.frame(date = d,
                    dsn = paste0("/vsicurl/", Sys.getenv("PUBLIC"), "/", x))
files <- files[order(files$date), ]
arrow::write_parquet(files, "chlfiles.parquet")
dd <- diff(files$date)
cat(sprintf("%i composites, %s .. %s; steps (days): %s\n", nrow(files),
            min(files$date), max(files$date),
            paste(names(table(dd)), table(dd), sep = "x", collapse = " ")))
gap <- which(dd > 6)
if (length(gap)) cat("gaps after:", format(files$date[gap]), "\n")
R

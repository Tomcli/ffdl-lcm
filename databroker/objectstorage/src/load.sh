#!/bin/bash

#-------------------------------------------------------------
# IBM Confidential
# OCO Source Materials
# (C) Copyright IBM Corp. 2016
# The source code for this program is not published or
# otherwise divested of its trade secrets, irrespective of
# what has been deposited with the U.S. Copyright Office.
#-------------------------------------------------------------

# Download files from Object Storage to $DATA_DIR.

# Validate input.
: "${DATA_DIR:?Need to set DATA_DIR to non-empty value}"
: "${DATA_STORE_BUCKET:?Need to set DATA_STORE_BUCKET to non-empty value}"
: "${DATA_STORE_USERNAME:?Need to set DATA_STORE_USERNAME to non-empty value}"
: "${DATA_STORE_PASSWORD:?Need to set DATA_STORE_PASSWORD to non-empty value}"
: "${DATA_STORE_AUTHURL:?Need to set DATA_STORE_AUTHURL to non-empty value}"

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTDIR/utility.sh"

trap panic ERR # exit immediately on error

constructSwiftConnectionArgs
echo Connection args: "${SWIFT_CONNECTION_ARGS[@]}"

echo Using Object Storage account $DATA_STORE_USERNAME at $DATA_STORE_AUTHURL

# Download data.
echo Download start: $(date)
echo "Downloading from bucket $DATA_STORE_BUCKET to $DATA_DIR"
mkdir -p "$DATA_DIR"
time with_backoff swift --verbose "${SWIFT_CONNECTION_ARGS[@]}" download -D "$DATA_DIR" "$DATA_STORE_BUCKET"
echo Download end: $(date)

# store monitoring event with data download size
download_size=$(du --max-depth 0 "$DATA_DIR" | awk '{print $1}')
pushMetrics "dataloader.swift.download.size:$download_size|h" &

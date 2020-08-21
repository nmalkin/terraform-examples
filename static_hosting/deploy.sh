#!/bin/sh

aws s3 sync /path/to/build s3://bucket.name/directory
# With Create React App, index.html gets updated with paths to the new bundles, so we don't want it cached.
aws s3 cp --cache-control max-age=0 /path/to/buildindex.html s3://bucket.name/path/index.html

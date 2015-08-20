#!/bin/sh

set -e

sbcl --noinform <<EOF
(ql:update-client :prompt nil)
EOF

sbcl --noinform <<EOF
(ql:update-all-dists :prompt nil)
EOF

echo done

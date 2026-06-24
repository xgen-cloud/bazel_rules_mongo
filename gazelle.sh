#!/usr/bin/env bash

# 'bazel mod tidy' is now necessary after dep updates, and we can't address that in-tree, so we have to create a shell script intermediary.

@@BASH_RLOCATION_FUNCTION@@

set -euo pipefail
gazelle="$(rlocation @@gazelle@@)"
(cd "$BUILD_WORKSPACE_DIRECTORY" && BAZELISK_SKIP_WRAPPER=true bazel mod tidy --config=veryquiet)
"$gazelle"
(cd "$BUILD_WORKSPACE_DIRECTORY" && BAZELISK_SKIP_WRAPPER=true bazel mod tidy --config=veryquiet)

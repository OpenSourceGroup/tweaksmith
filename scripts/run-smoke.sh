#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export TWEAKSMITH_TEST_ISOLATED_PREFS=1
swift run TweaksmithCoreSmoke

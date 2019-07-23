#!/usr/bin/env bash

# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

TOOL_VERSION=4dc3d6f908138504b02a1766f1f8ea282d6bdd7c

# cd to the root path
ROOT=$(dirname "${BASH_SOURCE}")/..
cd ${ROOT}
GO111MODULE=on go get "github.com/tallclair/mdtoc@${TOOL_VERSION}"

echo "Checking table of contents are up to date..."
# Verify tables of contents are up-to-date
grep --include='*.md' -rl keps -e '<!-- toc -->' | xargs mdtoc --inplace --dryrun

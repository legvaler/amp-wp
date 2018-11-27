#!/bin/bash
#
#   This file is part of the AMP Plugin for WordPress.
#
#   The AMP Plugin for WordPress is free software: you can redistribute
#   it and/or modify it under the terms of the GNU General Public
#   License as published by the Free Software Foundation, either version 2
#   of the License, or (at your option) any later version.
#
#   The AMP Plugin for WordPress is distributed in the hope that it will
#   be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with the AMP Plugin for WordPress. If not, see <https://www.gnu.org/licenses/>.
#

set -e

tag=$(git describe --tags)
if [[ -z "$tag" ]]; then
    echo "Error: Unable to determine tag."
    exit 1
fi

built_tag="$tag-built"
if git rev-parse "$built_tag" >/dev/null 2>&1; then
    echo "Error: Built tag already exists: $built_tag"
    exit 2
fi

if ! git diff-files --quiet || ! git diff-index --quiet --cached HEAD --; then
    echo "Error: Repo is in dirty state"
    exit 3
fi

git checkout "$tag"
npm run build
mkdir built
git clone . built/
cd built
git checkout $tag
git rm -r $(git ls-files)
rsync -avz ../build/ ./
git add -A .
git commit -m "Build $tag" --no-verify
git tag "$built_tag"
git push origin "$built_tag"
cd ..
git push origin "$built_tag"
rm -rf built

echo "Pushed tag $built_tag."
echo "See https://github.com/Automattic/amp-wp/releases/tag/$built_tag"
echo "For https://github.com/Automattic/amp-wp/releases/tag/$tag"

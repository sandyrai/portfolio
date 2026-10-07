#!/usr/bin/env bash
# ---------------------------------------------------------
# deploy.sh: publish the committed portfolio to the VPS
# ---------------------------------------------------------
#
#   bash deploy/deploy.sh            deploy the last commit to /var/www/portfolio
#   bash deploy/deploy.sh --stage    first time only: upload to ~/portfolio-release
#                                    and ~/portfolio.caddy for the one-time root setup
#
# Ships only the public files of HEAD (never README, deploy/ or .git),
# keeps the previous version in ~/portfolio-prev, and checks the live
# URL afterwards, restoring the previous version if it doesn't respond.
# ---------------------------------------------------------
set -euo pipefail

VPS="${VPS:-ojdeploy@93.127.185.236}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/ojasyukti-actions-deploy}"
URL="https://sandeep.ojasyukti.tech/"
PUBLIC=(index.html 404.html favicon.svg robots.txt sitemap.xml site.webmanifest assets)

cd "$(dirname "$0")/.."
if [[ -n "$(git status --porcelain)" ]]; then
    git status --short
    echo "error: uncommitted changes. Commit first; only the last commit is deployed." >&2
    exit 1
fi
sha=$(git rev-parse --short HEAD)
vps() { ssh -i "$SSH_KEY" -o BatchMode=yes "$VPS" "$@"; }

if [[ "${1:-}" == "--stage" ]]; then
    git archive HEAD "${PUBLIC[@]}" | vps "rm -rf ~/portfolio-release && mkdir -p ~/portfolio-release \
        && tar -xf - -C ~/portfolio-release && chmod -R a+rX ~/portfolio-release"
    vps "cat > ~/portfolio.caddy" < deploy/Caddyfile.snippet
    echo "staged $sha in ~/portfolio-release and the site block in ~/portfolio.caddy"
    exit 0
fi

echo "==> deploying $sha to $VPS:/var/www/portfolio"
git archive HEAD "${PUBLIC[@]}" | vps '
    set -euo pipefail
    root=/var/www/portfolio
    [[ -w $root ]] || { echo "error: $root missing or not writable; run the one-time setup in README.md" >&2; exit 1; }
    inc=$(mktemp -d); trap "rm -rf $inc" EXIT
    tar -xf - -C "$inc"
    [[ -f $inc/index.html ]] || { echo "error: no index.html in upload" >&2; exit 1; }
    chmod -R a+rX "$inc"; chmod 755 "$inc"
    rm -rf ~/portfolio-prev && cp -a "$root" ~/portfolio-prev
    find "$root" -mindepth 1 -delete
    cp -a "$inc/." "$root/"
'

if curl -fsS -m 15 -o /dev/null "$URL"; then
    echo "✓ live at $URL ($sha)"
else
    echo "error: $URL did not respond; restoring the previous version" >&2
    vps 'find /var/www/portfolio -mindepth 1 -delete && cp -a ~/portfolio-prev/. /var/www/portfolio/'
    exit 1
fi

#!/usr/bin/env bash
# Local build + start for this fork (see ../PLANO.md).
#
# Docker Desktop's DNS proxy drops many lookups on this machine and BuildKit's /etc/resolv.conf is read-only,
# so the hosts the build downloads from are resolved here on the host and passed with --add-host.
#
# Usage: ./local-build.sh            (build image + docker compose up -d)
#        DOCKER_CONFIG=/path ./local-build.sh   (e.g. a config without credsStore for anonymous pulls)
set -euo pipefail
cd "$(dirname "$0")"

HOSTS=(
  dl-cdn.alpinelinux.org
  registry.npmjs.org
  github.com
  codeload.github.com
  binaries.prisma.sh
)

ADD_HOSTS=()
for h in "${HOSTS[@]}"; do
  ip=$(getent ahostsv4 "$h" | awk 'NR==1{print $1}')
  if [[ -z "$ip" ]]; then
    echo "could not resolve $h on the host" >&2
    exit 1
  fi
  echo "  $h -> $ip"
  ADD_HOSTS+=(--add-host "$h:$ip")
done

docker build --progress=plain "${ADD_HOSTS[@]}" -f Dockerfile.local -t evolution-api-galin-gds:local .
docker compose -f docker-compose.local.yaml up -d --no-build

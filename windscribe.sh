#!/usr/bin/env bash

timestamp=$(date +%s)
json=$(curl -s "https://assets.windscribe.com/serverlist/mob-v2/1/$timestamp")

{
  printf '| Server Name | City | Nickname | TZ | GPS | wg_pubkey | wg_endpoint | ovpn_x509 | Ping IP | Link Speed | Node Hostname | IP | IP2 | IP3 | Node Weight | Node Health |\n'
  printf '|-------------|------------|----------|----|-----|-----------|-------------|------------|---------|-------------|----------------|----|-----|-----|--------------|--------------|\n'

  echo "$json" | jq -r '
    .data[] as $srv |
    ($srv.groups // [])[]? as $grp |
    ($grp.nodes // [])[]? as $node |
    [
      $srv.name,
      ($grp.city // ""),
      ($grp.nick // ""),
      ($grp.tz // ""),
      ($grp.gps // ""),
      ($grp.wg_pubkey // ""),
      ($grp.wg_endpoint // ""),
      ($grp.ovpn_x509 // ""),
      ($grp.ping_ip // ""),
      ($grp.link_speed // ""),
      ($node.hostname // ""),
      ($node.ip // ""),
      ($node.ip2 // ""),
      ($node.ip3 // ""),
      ($node.weight | tostring),
      ($node.health | tostring)
    ] | @tsv
  ' | awk -F'\t' '{
    printf "| %-11s | %-7s | %-6s | %-11s | %-8s | %-6s | %-7s | %-44s | %-21s | %-12s | %-9s | %-11s | %-14s | %-15s | %-15s | %-15s | %-12s | %-12s |\n", \
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
  }'
} > Readme.md

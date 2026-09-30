#!/bin/bash
# scripts/jrn.sh <nom-log> <commande...>
# Journalise la commande et son code retour dans docs/logs/commands.log,
# capture la sortie brute dans docs/logs/<nom-log>.log et affiche la fin.
cd "$(dirname "$0")/.." || exit 1
name="$1"; shift
mkdir -p docs/logs
printf '[%s] $ %s\n' "$(date -Iseconds)" "$*" >> docs/logs/commands.log
start=$(date +%s)
"$@" > "docs/logs/$name.log" 2>&1
rc=$?
end=$(date +%s)
printf '[%s] rc=%s duree=%ss log=docs/logs/%s.log\n' "$(date -Iseconds)" "$rc" "$((end-start))" "$name" >> docs/logs/commands.log
tail -n 30 "docs/logs/$name.log"
printf '%s exit=%s duree=%ss\n' "$name" "$rc" "$((end-start))"
exit $rc

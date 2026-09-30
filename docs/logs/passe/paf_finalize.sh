#!/bin/bash
set -u
REPO="/Users/bf/Library/CloudStorage/GoogleDrive-bernynoussi@gmail.com/Mon Drive/Formation/Collège BDEB/ETE_2026/420-A60-BB ALGORITHMES D'APPRENTISSAGE PROFOND/Examen Final/PasteAsFile"
cd "$REPO" || exit 1
chmod +x scripts/*.sh
bash scripts/verify.sh > docs/logs/verify_run.log 2>&1
echo "verify.sh rc=$?"
grep -E "^(V1|V2|V3-app|V3-finder|V4-plist|V4-point|V4-sandbox|V5) exit=" docs/logs/verify_run.log
echo "=== git status ==="
git status --porcelain=v1
echo "=== racine du depot ==="
ls -a

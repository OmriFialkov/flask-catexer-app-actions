#!/bin/bash

# Clone the Helm repo
echo "cloning github pages helm repo to make changes.."
git clone https://${HELM_REPO_PAT}@github.com/OmriFialkov/helm-flaskgif.git helmrepo
cd helmrepo || exit 1

set -x

# Update package list and install git-restore-mtime
echo "Installing git-restore-mtime..."
sudo apt-get update && sudo apt-get install -y git-restore-mtime

echo "Restoring original modification times..."
/usr/lib/git-core/git-restore-mtime
ls -ltr

# Use mapfile command to correctly list all .tgz files sorted by oldest first
mapfile -t TGZ_FILES < <(ls -tr *.tgz 2>/dev/null)

# Debugging: Print all files
echo "Found: ${TGZ_FILES[*]}"

# delete the oldest ones, keeping only the 3 newest tgzs.
while [ "${#TGZ_FILES[@]}" -gt 3 ]; do
    echo "Deleting: ${TGZ_FILES[0]}"
    rm -f "${TGZ_FILES[0]}"  # Delete the oldest
    TGZ_FILES=("${TGZ_FILES[@]:1}")  # :1 starts from the second element - actually removing 0 index.
done

ls

# Rebuild Helm index - to show only existing .tgz files - avoid conflicts ?
echo "Regenerating index.yaml to include only the remaining 3 .tgz files..."
rm -f index.yaml
helm repo index --url https://omrifialkov.github.io/helm-flaskgif .

git config --global user.email "heyits@atester"
git config --global user.name "helm-chart-auto-cleanup"

git add -A
git commit -m "Updated index.yaml after older tgzs cleanup"
git push origin main
echo "cleanup completed, changes pushed to GitHub - Pages helm-flaskgif repo."
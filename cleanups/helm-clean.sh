#!/bin/bash

# Clone the Helm repo
git clone https://${HELM_REPO_PAT}@github.com/OmriFialkov/helm-flaskgif.git helmrepo
cd helmrepo || exit 1

# Use 'find' to correctly list all .tgz files sorted by oldest first
mapfile -t TGZ_FILES < <(ls -tr *.tgz 2>/dev/null)

# Debugging: Print all files
echo "Found: ${TGZ_FILES[*]}"

# delete the oldest ones, keeping only the 3 newest tgzs.
while [ "${#TGZ_FILES[@]}" -gt 3 ]; do
    echo "Deleting: ${TGZ_FILES[0]}"
    rm -f "${TGZ_FILES[0]}"  # Delete the oldest
    TGZ_FILES=("${TGZ_FILES[@]:1}")  # Remove first element
done

ls

# Rebuild Helm index - to show only existing .tgz files - avoid conflicts ?
echo "Regenerating index.yaml to include only the remaining 3 .tgz files..."
rm -f index.yaml
helm repo index --url https://omrifialkov.github.io/helm-flaskgif .

git add -A
git commit -m "Updated index.yaml after older tgzs cleanup"
git push origin main
echo "cleanup completed, changes pushed to GitHub - Pages helm-flaskgif repo."

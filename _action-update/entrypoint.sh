#!/bin/sh -l

set -eu
. /opt/venv/bin/activate

# Check hub installation
hub version

# Requires BRANCH_NAME, BOT_USER, BOT_TOKEN to be included by workflow
export GITHUB_API_TOKEN=$BOT_TOKEN

#ACT_LOG_PATH=_explore/LAST_MASTER_UPDATE.txt
#ACT_INPUT_PATH=_explore
#ACT_DATA_PATH=explore/github-data

DATA_TIMESTAMP=$(date -u "+%F-%H")
#CLONE_CUTOFF=$(date -u "+%F" -d "7 days ago")

# Configure git + hub
git config --global user.name "${BOT_USER}"
git config --global user.email "${BOT_USER}@users.noreply.github.com"
git config --global hub.protocol https

# Get latest copy of repository
git clone --no-single-branch "https://${BOT_USER}:${BOT_TOKEN}@github.com/usnistgov/nist-software-scraper.git"
cd nist-software-scraper
REPO_SCRAPER=$(pwd)

cd $REPO_SCRAPER
# Install python dependencies
pip install -r requirements.txt

# Build scraper
python setup.py install

git clone --no-single-branch "https://${BOT_USER}:${BOT_TOKEN}@github.com/usnistgov/opensource.git"
cd opensource
REPO_ROOT=$(pwd)

# Checkout data update branch, creating new if necessary
git checkout $BRANCH_NAME || git checkout -b $BRANCH_NAME
git merge --no-edit master

# Store previous END timestamp
OLD_END=$(cat $ACT_LOG_PATH | grep END | cut -f 2)
OLD_END=$(date --date="$OLD_END" "+%s")

# Run MASTER script
scraper --config $REPO_SCRAPER/nist_config.json

git add -A .

### COMMIT UPDATE ###
git pull
git commit -m "${DATA_TIMESTAMP} Data Update by ${BOT_USER}"
git push origin $BRANCH_NAME

### MERGE TO NIST-PAGES
git checkout nist-pages
git merge $BRANCH_NAME
git add -A .
git commit -m "${DATA_TIMESTAMP} Data Merge to ${BOT_USER}"
git push origin nist-pages

#push in

# Create pull request, or list existing
# hub pull-request --no-edit --message "Data Update by ${BOT_USER}" || hub pr list --state open --head $BRANCH_NAME

exit 0

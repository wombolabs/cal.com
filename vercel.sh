# github submodule repo address without https:// prefix
SUBMODULE_GITHUB=github.com/calcom/website

# .gitmodules submodule path
SUBMODULE_PATH=apps/website

# github access token is necessary
# add it to Environment Variables on Vercel
if [ "$GITHUB_ACCESS_TOKEN" == "" ]; then
  echo "Error: GITHUB_ACCESS_TOKEN is empty"
  exit 1
fi

# stop execution on error - don't let it build if something goes wrong
set -e

# get submodule commit
output=`git submodule status --recursive` # get submodule info

echo $output
# -378cbf8f3a67ea7877296f1da02edb2b6e3efbce apps/api -e0330f75d7cc499b490d7071d67c7761f5b9a6b3 apps/website

IFS='-' read -r -a submodules <<< "$output"

for n in submodules
do
    echo "submodule: $n"
done

no_prefix=${output#*-} # get rid of the prefix
COMMIT=${no_prefix% *} # get rid of the suffix

echo $COMMIT
# 378cbf8f3a67ea7877296f1da02edb2b6e3efbce apps/api -e0330f75d7cc499b490d7071d67c7761f5b9a6b3

# set up an empty temporary work directory
rm -rf tmp || true # remove the tmp folder if exists
mkdir tmp # create the tmp folder
cd tmp # go into the tmp folder

# checkout the current submodule commit
git config --global init.defaultBranch main
git config --global advice.detachedHead false
git init # initialise empty repo
git remote add origin https://$GITHUB_ACCESS_TOKEN@$SUBMODULE_GITHUB # add origin of the submodule
git fetch --depth=1 origin $COMMIT # fetch only the required version
git checkout $COMMIT # checkout on the right commit

# move the submodule from tmp to the submodule path
cd .. # go folder up
rm -rf tmp/.git # remove .git 
mv tmp/* $SUBMODULE_PATH/ # move the submodule to the submodule path

# clean up
rm -rf tmp # remove the tmp folder

#!/bin/bash

## Description: Deploy next version. Available options are --patch, --minor, --major
## Usage: deploy-next

VERSION_TYPE="patch"

for arg in "$@"; do
  case $arg in
    --patch)
      VERSION_TYPE="patch"
      shift
      ;;
    --minor)
      VERSION_TYPE="minor"
      shift
      ;;
    --major)
      VERSION_TYPE="major"
      shift
      ;;
    *)
      echo "Invalid option: $arg" >&2
      exit 1
      ;;
  esac
done

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then

   if [ -n "$(git status --porcelain)" ]; then
     echo "Error: Repository has uncommitted changes. Exiting."
     exit 1
   fi

  TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
  IFS='.' read -r -a VERSION_PARTS <<< "$TAG"

  case $VERSION_TYPE in
    "patch")
      NEW_TAG="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.$((VERSION_PARTS[2]+1))"
      ;;
    "minor")
      NEW_TAG="${VERSION_PARTS[0]}.${VERSION_PARTS[1]+1}.0"
      ;;
    "major")
      NEW_TAG="$((VERSION_PARTS[0]+1)).0.0"
      ;;
  esac

  awk -v new_tag="$NEW_TAG" '{gsub(/sourcebrokergit\/deployer-typo3-ci\/[^\/]*/, "sourcebrokergit/deployer-typo3-ci/" new_tag)}1' ci/provider/gitlab/main.yml > ci/provider/gitlab/main.tmp && mv ci/provider/gitlab/main.tmp ci/provider/gitlab/main.yml
  awk -v new_tag="$NEW_TAG" '{gsub(/sourcebrokergit\/deployer-typo3-ci\/[^\/]*/, "sourcebrokergit/deployer-typo3-ci/" new_tag)}1' ci/provider/gitlab/config/600-deploy.yaml > ci/provider/gitlab/config/600-deploy.tmp && mv ci/provider/gitlab/config/600-deploy.tmp ci/provider/gitlab/config/600-deploy.yaml
  git add ci/provider/gitlab/main.yml
  git add ci/provider/gitlab/config/600-deploy.yaml
  git commit -m "Update include paths to tag $NEW_TAG"

  git tag -a "$NEW_TAG" -m "$NEW_TAG"
  echo "To push the new tag, run: git push origin main --tags"
else
  echo "Not on main or master branch, aborting."
fi
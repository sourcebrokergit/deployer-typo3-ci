#!/bin/sh

if [ -n "$CI_COMMIT_TAG" ]; then
  export DEPLOYER_SELECTOR="$DEPLOYER_SELECTOR_FOR_TAG"
  export DEPLOYER_BT="--tag=${CI_COMMIT_TAG}"
else
  IFS=',' read -ra MAPPINGS <<< "$DEPLOYER_SELECTOR_FOR_BRANCH"
  for mapping in "${MAPPINGS[@]}"; do
    IFS=':' read -ra PAIR <<< "$mapping"
    if [ "${PAIR[0]}" == "$CI_COMMIT_BRANCH" ]; then
      export DEPLOYER_SELECTOR="${PAIR[1]}"
      export DEPLOYER_BT="--branch=${CI_COMMIT_BRANCH}"
      break
    fi
  done
  if [ -z "$DEPLOYER_SELECTOR" ]; then
    echo "Neither tag pushed or branch '${CI_COMMIT_BRANCH}' is not found in DEPLOY_TRIGGER_BY_CI_COMMIT_BRANCH. Exiting job."
    exit 0
  fi
fi
if [ -z "$DEPLOYER_SELECTOR" ]; then
  echo "DEPLOYER_SELECTOR is empty. Exiting job."
  exit 0
fi
echo "DEPLOYER_SELECTOR: $DEPLOYER_SELECTOR"
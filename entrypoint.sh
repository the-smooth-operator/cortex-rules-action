#!/bin/sh
#
# Interact with the Cortex Ruler API using the cortextool

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: " + "$@" >&2
}

# For commands that interact with the server, we need to verify that the
# CORTEX_TENANT_ID and CORTEX_ADDRESS are set.
verifyTenantAndAddress() {
  if [ -z "${CORTEX_TENANT_ID}" ]; then
    err "CORTEX_TENANT_ID has not been set."
    exit 1
  fi

  if [ -z "${CORTEX_ADDRESS}" ]; then
    err "CORTEX_ADDRESS has not been set."
    exit 1
  fi
}

LINT_CMD=lint
CHECK_CMD=check
PREPARE_CMD=prepare
SYNC_CMD=sync
DIFF_CMD=diff

if [ -z "${RULES_DIR}" ]; then
  echo "RULES_DIR not set, using './' as a default."
  RULES_DIR="./"
fi

if [ -z "${ACTION}" ]; then
  err "ACTION has not been set."
  exit 1
fi

case "${ACTION}" in
  $SYNC_CMD)
    verifyTenantAndAddress
    OUTPUT=$(/usr/bin/cortextool rules sync --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  $DIFF_CMD)
    verifyTenantAndAddress
    OUTPUT=$(/usr/bin/cortextool rules diff --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  $LINT_CMD)
    OUTPUT=$(/usr/bin/cortextool rules lint --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  $PREPARE_CMD)
    OUTPUT=$(/usr/bin/cortextool rules prepare -i --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  $CHECK_CMD)
    OUTPUT=$(/usr/bin/cortextool rules check --rule-dirs="${RULES_DIR}")
    STATUS=$?
    ;;
  *)
    err "Unexpected action '${ACTION}'"
    exit 1
    ;;
esac

echo "${OUTPUT}"
echo ::set-output name=detailed::"${OUTPUT}"
SUMMARY=$(echo "${OUTPUT}" | grep Summary)
echo ::set-output name=summary::"${SUMMARY}"

exit $STATUS

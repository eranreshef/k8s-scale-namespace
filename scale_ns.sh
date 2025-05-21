#!/bin/bash

label_key="original-replicas"

# ---- Scaling Function ----
scale_resource() {
    kind="$1"

    # kubectl get "$kind" --context "$CLUSTER" -n "$NAMESPACE" -o json | jq -c '.items[]' | while read -r obj; do
    local json
    if ! json=$(kubectl get "$kind" -n "$NAMESPACE" -o json 2>/dev/null); then
      echo "Error: Failed to get $kind in namespace $NAMESPACE"
      return 1
    fi

    # Use a regular Bash loop over jq-parsed lines
    echo "$json" | jq -c '.items[]' | while IFS= read -r obj; do
        name=$(echo "$obj" | jq -r '.metadata.name')
        replicas=$(echo "$obj" | jq -r '.spec.replicas')

        if [[ "$DIRECTION" == "down" ]]; then
            echo "Scaling down $kind/$name from $replicas to 0"
            kubectl --context "$CLUSTER" -n "$NAMESPACE" label "$kind" "$name" "$label_key=$replicas" --overwrite
            kubectl --context "$CLUSTER" -n "$NAMESPACE" scale "$kind" "$name" --replicas=0
        elif [[ "$DIRECTION" == "up" ]]; then
            original=$(echo "$obj" | jq -r ".metadata.labels[\"$label_key\"]")
            if [[ "$original" == "null" ]]; then
                echo "Skipping $kind/$name (no original-replicas label)"
                continue
            fi
            echo "Scaling up $kind/$name to $original"
            kubectl --context "$CLUSTER" -n "$NAMESPACE" scale "$kind" "$name" --replicas="$original"
            kubectl --context "$CLUSTER" -n "$NAMESPACE" label "$kind" "$name" "$label_key"- # remove label
        else
            echo "Invalid direction: $DIRECTION"
            return 1
        fi
    done
}

scale_ns() {
    # ---- Dependency Check ----
    REQUIRED_CMDS=("kubectl" "jq")

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: '$cmd' is not installed or not in PATH."
            return 1
        fi
    done

    # ---- Argument Parsing ----
    CLUSTER="$1"
    NAMESPACE="$2"
    DIRECTION="$3"

    if [[ -z "$CLUSTER" || -z "$NAMESPACE" || -z "$DIRECTION" ]]; then
        echo "Usage: $0 <cluster-name> <namespace> [up|down]"
        return 1
    fi
    # ---- Main Execution ----
    for resource in deployments statefulsets; do
        scale_resource "$resource"
    done

    echo "Done."
}

scale_ns "$@"
# ---- End of Script ----

#!/usr/bin/env bash
# Run inside the authenticated IBM Skills Network lab, from the repository root.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
mode="${1:-help}"
registry="${ICR_REGISTRY:-us.icr.io}"
app_name="${APP_NAME:-tax-calculator}"

require_cloud() {
  : "${SN_ICR_NAMESPACE:?Set SN_ICR_NAMESPACE to the namespace assigned by the IBM lab}"
  [[ "$SN_ICR_NAMESPACE" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo 'Invalid registry namespace.' >&2; exit 1; }
  image="$registry/$SN_ICR_NAMESPACE/tax-calculator"
  command -v ibmcloud >/dev/null
}

case "$mode" in
  container)
    npm ci --no-audit --no-fund
    printf '$ npx jasmine\n' > evidence/01-jasmine-tests-passing.txt
    npx jasmine --no-color 2>&1 | tee -a evidence/01-jasmine-tests-passing.txt
    cp Dockerfile evidence/02-dockerfile.txt
    printf '$ docker build -t tax-calculator:latest .\n' > evidence/03-docker-build-output.txt
    docker build --progress=plain -t tax-calculator:latest . 2>&1 | tee -a evidence/03-docker-build-output.txt
    docker run -d --name "$app_name" -p 8080:80 tax-calculator:latest
    printf '$ docker ps\n' > evidence/04-docker-image.txt
    docker ps --filter "name=$app_name" | tee -a evidence/04-docker-image.txt
    curl --retry 10 --retry-connrefused --retry-delay 1 --fail http://localhost:8080/ -o /tmp/tax-calculator-page.html
    grep -q 'Tax Calculator' /tmp/tax-calculator-page.html
    ;;
  publish)
    require_cloud
    ibmcloud cr login --client docker
    docker tag tax-calculator:latest "$image:v1"
    printf '$ docker push %s\n' "$image:v1" > evidence/05-docker-icr-push.txt
    docker push "$image:v1" 2>&1 | tee -a evidence/05-docker-icr-push.txt
    ;;
  cloud)
    require_cloud
    printf '$ ibmcloud ce application create --name %s --image %s --registry-secret icr-secret --port 80\n' "$app_name" "$image:v1" > evidence/06-deployed-on-cloud.txt
    ibmcloud ce application create --name "$app_name" --image "$image:v1" --registry-secret icr-secret --port 80 --cpu 0.25 --memory 0.5G --min-scale 0 --max-scale 1 2>&1 | tee -a evidence/06-deployed-on-cloud.txt
    ibmcloud ce application get --name "$app_name" 2>&1 | tee -a evidence/06-deployed-on-cloud.txt
    ;;
  pipeline)
    require_cloud
    kubectl get secret docker-reg-creds -n "$SN_ICR_NAMESPACE" >/dev/null
    kubectl apply -f tasks.yaml -f pipeline.yaml -n "$SN_ICR_NAMESPACE"
    run_name="$(kubectl create -f run.yaml -n "$SN_ICR_NAMESPACE" -o jsonpath='{.metadata.name}')"
    printf '%s\n' "$run_name" > evidence/pipeline-run-name.txt
    tkn pipelinerun logs "$run_name" -n "$SN_ICR_NAMESPACE" -f 2>&1 | tee evidence/09-tekton-pipeline-output.txt
    kubectl wait --for=condition=Succeeded "pipelinerun/$run_name" -n "$SN_ICR_NAMESPACE" --timeout=1800s
    kubectl get "pipelinerun/$run_name" -n "$SN_ICR_NAMESPACE" -o json > evidence/pipeline-run.json
    ;;
  release)
    require_cloud
    run_name="$(cat evidence/pipeline-run-name.txt)"
    kubectl wait --for=condition=Succeeded "pipelinerun/$run_name" -n "$SN_ICR_NAMESPACE" --timeout=30s
    digest="$(python3 -c 'import json; d=json.load(open("evidence/pipeline-run.json")); s=d["status"]; print(next(x["value"] for x in s.get("results",s.get("pipelineResults",[])) if x["name"]=="IMAGE_DIGEST"))')"
    [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || { echo 'Missing valid pipeline image digest.' >&2; exit 1; }
    ibmcloud ce application update --name "$app_name" --image "$image@$digest" --registry-secret icr-secret --port 80 2>&1 | tee evidence/10-pipeline-deployment.txt
    ibmcloud ce application get --name "$app_name" 2>&1 | tee -a evidence/10-pipeline-deployment.txt
    echo 'Open the resulting IBM URL, calculate income 50000 and capture 10-final-output.jpg.'
    ;;
  *)
    echo 'Usage: bash scripts/lab.sh container|publish|cloud|pipeline|release'
    echo 'Requires authenticated IBM lab, assigned Code Engine project, Tekton context and the course registry secrets.'
    ;;
esac

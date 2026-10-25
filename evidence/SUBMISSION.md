# Tax Calculator — submission checklist

Repository: https://github.com/Alikhan808/tax-calculator-devops

Epic and stories: https://github.com/Alikhan808/tax-calculator-devops/issues

Actual successful verification: https://github.com/Alikhan808/tax-calculator-devops/actions/runs/40223298268

1. Paste 01-jasmine-tests-passing.txt — actual seven Jasmine specs, zero failures.
2. Paste 02-dockerfile.txt — Nginx Dockerfile, five COPY instructions.
3. Paste 03-docker-build-output.txt — actual successful Docker build output from GitHub Actions Ubuntu.
4. Paste 04-docker-image.txt — actual docker ps output, host port 8080, plus successful HTTP checks on that runner.
5. Pending actual IBM Container Registry push: 05-docker-icr-push.txt is created only after it succeeds in the lab.
6. Pending actual Code Engine deployment: 06-deployed-on-cloud.txt is created by the lab command.
7. https://github.com/Alikhan808/tax-calculator-devops/blob/main/tasks.yaml
8. https://github.com/Alikhan808/tax-calculator-devops/blob/main/pipeline.yaml
9. https://github.com/Alikhan808/tax-calculator-devops/blob/main/run.yaml — the image registry namespace is derived from the PipelineRun namespace; execute in the lab-assigned namespace.
10. Pending actual pipeline-image deployment and 10-final-output screenshot.

local-preview.jpg is a local browser preview. Do not submit it as evidence of an IBM Cloud deployment.

## Continue inside the IBM lab

Clone this repository. The lab must provide an authenticated IBM account, a selected Code Engine project, the registry namespace, Tekton cluster context and permitted pipeline service account. Tekton uses the course registry Secret docker-reg-creds; Code Engine uses icr-secret. Select the appropriate Kubernetes context before running the pipeline. Run these stages in order:

```sh
bash scripts/lab.sh container
bash scripts/lab.sh publish
bash scripts/lab.sh cloud
bash scripts/lab.sh pipeline
bash scripts/lab.sh release
```

The scripts stop on an error. Credentials are not included in the repository or this package. Confirm the assigned registry region before publishing; ICR_REGISTRY defaults to us.icr.io.

## Reference documentation

- IBM JavaScript starter: https://github.com/ibm-developer-skills-network/zntwk-tax_calculator
- Tekton Pipeline API: https://tekton.dev/docs/pipelines/pipelines/
- IBM Code Engine CLI: https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli
- IBM Container Registry getting started: https://cloud.ibm.com/docs/Registry?topic=Registry-getting-started

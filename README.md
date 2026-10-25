# Tax Calculator — IBM Cloud Native final project

Repository: https://github.com/Alikhan808/tax-calculator-devops

Based on IBM's Apache-2.0 licensed [JavaScript starter](https://github.com/ibm-developer-skills-network/zntwk-tax_calculator). Original tax logic, seven Jasmine specifications, package lock and license are preserved. The interface validates whole-dollar income, including zero, and needs no external frontend libraries.

## Run and test

```sh
npm ci
npx jasmine
python3 -m http.server 8080
```

Open http://localhost:8080 and calculate an income of 50000. The course model returns tax due 6307.16 and effective rate 12.61%. Bracket constants are educational course fixtures, not a current tax-filing model.

## Docker

```sh
docker build -t tax-calculator:latest .
docker run -d --name tax-calculator -p 8080:80 tax-calculator:latest
docker ps
curl --fail http://localhost:8080/
```

The Dockerfile begins with FROM nginx and copies the five required files. GitHub Actions repeats the Jasmine, Docker build and container HTTP checks and uploads actual outputs as the tax-calculator-verification artifact. These are identified as runner results, not IBM Cloud deployment evidence.

## Tekton

- [tasks.yaml](tasks.yaml): clone, npm, jasmine and buildah tasks.
- [pipeline.yaml](pipeline.yaml): clone → npminstall → tests → build; returns the registry image digest.
- [run.yaml](run.yaml): PipelineRun parameters and workspace bindings.

Requires Tekton Pipelines with the stable tekton.dev/v1 API, a default storage class, and a Docker registry Secret named icr-secret. Buildah requires a lab service account permitted to execute privileged builds. This project does not grant cluster permissions. Replace REPLACE_WITH_LAB_REGISTRY_NAMESPACE in run.yaml with the assigned registry namespace.

```sh
kubectl apply -f tasks.yaml -f pipeline.yaml
kubectl create -f run.yaml
tkn pipelinerun logs --last -f
```

Cloud and pipeline execution evidence must come from the authenticated IBM lab. Source files alone do not establish that an image was pushed or deployed.

## Attribution and planning

See LICENSE for IBM's Apache-2.0 license and [docs/PLAN.md](docs/PLAN.md) for the modernization epic and stories.

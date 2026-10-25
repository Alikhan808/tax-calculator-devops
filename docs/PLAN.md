# Epic: Modernize the Tax Calculator delivery process

As the application owner, I want a tested, containerized Tax Calculator with reproducible delivery to IBM Cloud, so that releases can be verified and deployed consistently.

## Story 1 — Automated unit tests
As a developer, I want the supplied Jasmine specifications to detect calculation regressions before packaging.

Acceptance: npx jasmine reports seven specs and zero failures; a failed spec produces a nonzero exit; actual output is saved as 01-jasmine-tests-passing.

## Story 2 — Containerize the application
As an operator, I want an Nginx image containing the five required static files so that the application runs consistently.

Acceptance: Dockerfile starts with FROM nginx and has one COPY per file; docker build succeeds; the container serves HTTP on host port 8080; docker ps and HTTP output are retained.

## Story 3 — Publish and deploy to IBM Cloud
As an operator, I want the tested image in IBM Container Registry and the assigned cloud project so that users can reach it.

Acceptance: registry push returns a digest; deployment is Ready; the application URL responds; actual outputs are retained for tasks 5 and 6.

## Story 4 — Introduce Tekton automation
As a developer, I want separate npm and Jasmine tasks so that failing tests prevent image publication.

Acceptance: tasks.yaml defines npm and jasmine; pipeline.yaml orders clone, npminstall, tests and build; run.yaml binds parameters and workspaces; a successful PipelineRun returns the pushed image digest.

## Story 5 — Release the pipeline-built image
As an operator, I want to deploy the exact image produced by a successful PipelineRun so that the release is traceable.

Acceptance: deploy the returned immutable image digest, verify income 50000, and capture 10-final-output from the actual IBM deployment. A local preview is not cloud deployment evidence.

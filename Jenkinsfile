#!/usr/bin/env groovy

node {
    step([
        $class: "GitHubCommitStatusSetter",
        commitShaSource: [$class: "ManuallyEnteredShaSource", sha: "ff4a02d7f9545fa07af214bae90ca55cf5ba564c"],
        reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/alphagov/whitehall"],
        contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "continuous-integration/jenkins/publishing-e2e-tests"],
        errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
        statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: "Testing Jenkins communications", state: "FAILED"]] ]
    ]);
}

**Shadoker** requires the following set of *Jenkins jobs* to operate:

| Script      | Job         | Usage |
|-------------|-------------|-------|
| [`build_changes_images`](./build_changes_images) | [Deployment/shadoker](http://jenkins.fircosoft.net/job/Deployment/job/shadoker) | tracks changes in the **master** branch and will build any modified images, or images whose dependencies have been modified |
| [`check_packages_and_images`](./check_packages_and_images) | [Deployment/shadoker-validate](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-validate) | verifies the validity of *references* and *Docker images* definition and reports the status into the corresponding branch and commit |
| [`update_package`](./update_package) | [Deployment/shadoker-update](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-update) | update the given *references*, typically triggered by the build CIs, see the [Shadoker artifact reference updating](http://confluence.fircosoft.net/display/DTP/Shadoker+artifact+reference+updating) article for more details |
| [`update_images`](./update_images) | [Deployment/shadoker-update-images](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-update-images) | inspects *Docker images* in the registry, and check for differences with shadoker *image references*. These are updated if necessary, and additional loopback scripts can be executed (e.g. for E2E, see job [Deployment/e2e-notification](http://jenkins.fircosoft.net/job/Deployment/job/e2e-notification)) |
| [`list_package_uris`](./list_package_uris) | [Deployment/shadoker-check-packages](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-check-packages) | periodically inspects all *references* to check the specified `uri` field still points to a valid resource. This job produces a [result table](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-check-packages/Package_URLs/). |
| [`list_products_assets`](./list_products_assets) | [Deployment/shadoker-assets](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-assets) | count all declared *products* and *assets* across *references* and *images*. This job produces a [result table](http://jenkins.fircosoft.net/job/Deployment/job/shadoker-assets/Assets/) and also publishes them to Graphite. |


Please see the [Shadoker usage for development teams](http://confluence.fircosoft.net/display/DTP/Shadoker+usage+for+development+teams) page on Confluence for all details and examples.

Contact: devops@accuity.com


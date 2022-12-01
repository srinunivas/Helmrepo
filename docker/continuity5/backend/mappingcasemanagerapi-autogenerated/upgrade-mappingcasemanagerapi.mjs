export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.MAPPINGCASEMANAGERAPI_VERSION}$`,
    product: 'continuity5',
    asset: 'mappingcasemanagerapi',
    component: 'mappingcasemanagerapi',
    buildDescFilenameFilterRegex: 'buildDesc-Linux-i686\\.json$',
    environments: {
      release: {
        generateLatestTags: false,
        branchPrefixFilter: 'release',
        autoPush: true,
        labels: {
          'maintainer': 'MESSEGUE Emmanuel <emmanuel.messegue@accuity.com>',
          'com.accuity.team': 'CONTINUITY',
          'com.accuity.project-name': 'CONTINUITY',
          'com.accuity.project-url': 'http://jira.fircosoft.net/projects/CONTINUITY'
        },
        onlyVersions: [
          `${process.env.MAPPINGCASEMANAGERAPI_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'upgrade-mappingcasemanagerapi',
            filter: 'Upgrade-MappingContinuityCaseManagerAPI',
          },
        ],
      },
      get develop() {
        return {
          ...this.release,
          generateLatestTags: false,
          branchPrefixFilter: 'develop',
        };
      },
    },
  }
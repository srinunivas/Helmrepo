export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.MAPPINGHTTPSTATUS_VERSION}.p`,
    product: 'continuity5',
    asset: 'mappinghttpstatus',
    component: 'mappinghttpstatus',
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
          `${process.env.MAPPINGHTTPSTATUS_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'mappinghttpstatus',
            filter: 'MappingContinuityHTTPStatus',
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
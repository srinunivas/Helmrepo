export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.FIRCOCONTRACTMAPPER_VERSION}.p`,
    product: 'continuity5',
    asset: 'fircocontractmapper',
    component: 'fircocontractmapper',
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
          `${process.env.FIRCOCONTRACTMAPPER_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'fircocontractmapper',
            filter: 'FircoContractMapper',
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
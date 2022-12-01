export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.DBTOOLS_VERSION}.p`,
    product: 'continuity5',
    asset: 'dbtools',
    component: 'dbtools',
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
          `${process.env.DBTOOLS_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'upgrade-dbtools',
            filter: 'Upgrade-ContinuityDBTools',
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
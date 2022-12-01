export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.DBCLIENT_VERSION}.p`,
    product: 'continuity5',
    asset: 'dbclient',
    component: 'dbclient',
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
          `${process.env.DBCLIENT_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'upgrade-dbclient',
            filter: 'Upgrade-ContinuityDBClient',
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
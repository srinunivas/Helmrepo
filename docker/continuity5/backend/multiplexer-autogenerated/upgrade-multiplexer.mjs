export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.MULTIPLEXER_VERSION}.p`,
    product: 'continuity5',
    asset: 'multiplexer',
    component: 'multiplexer',
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
          `${process.env.MULTIPLEXER_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'upgrade-multiplexer',
            filter: 'Upgrade-ContinuityMultiplexer',
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
export default {
    project: 'Continuity',
    product: 'continuity5',
    projectDirectoryFilter: `${process.env.FRONTEND_VERSION}.p`,
    asset: 'deployment-console',
    component: 'deployment-console',
    buildDescFilenameFilterRegex: 'buildDesc-Java\\.json$|-workflow\\.json$',
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
          `${process.env.FRONTEND_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'workflow',
            filter: 'Continuity-',
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
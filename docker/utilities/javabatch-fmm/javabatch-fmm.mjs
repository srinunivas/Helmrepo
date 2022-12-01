export default {
    project: 'Utilities',
    product: 'javabatch-fmm',
    projectDirectoryFilter: `${process.env.JDBCPROXY_VERSION}.p`,
    asset: 'javabatch-fmm',
    component: 'javabatch-fmm',
    buildDescFilenameFilterRegex: 'buildDesc-Java-javabatch-fmm\\.json$',
    environments: {
      release: {
        generateLatestTags: false,
        branchPrefixFilter: 'release',
        autoPush: true,
        labels: {
          'maintainer': 'THOME David <david.thome@accuity.com>',
          'com.accuity.team': 'UTILITIES',
          'com.accuity.project-name': 'UTILITIES',
          'com.accuity.project-url': 'http://jira.fircosoft.net/projects/UTILITIES'
        },
        onlyVersions: [
          `${process.env.JDBCPROXY_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'javabatch-fmm',
            filter: 'javabatch-fmm',
          },
        ],
        image: {
          type: 'backend',
          os: {
            name: 'alpine',
            versions: [
              'jre-11.0.11_9',
            ],
          },
          jdk: {
            name: 'openjdk',
            versions: [
              '11',
            ],
          },
        },
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
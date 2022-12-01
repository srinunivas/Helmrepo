export default {
    project: 'CoreEngine',
    product: 'continuity5',
    projectDirectoryFilter: `${process.env.JDBCPROXY_VERSION}.p`,
    asset: 'jdbcproxy',
    component: 'jdbcproxy',
    buildDescFilenameFilterRegex: 'buildDesc-Java-jdbcproxy\\.json$',
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
          `${process.env.JDBCPROXY_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'jdbcproxy',
            filter: 'jdbcproxy',
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
export default {
    project: 'Continuity',
    product: 'continuity5',
    projectDirectoryFilter: `${process.env.CONTINUITY_DB_VERSION}.p`,
    asset: 'database',
    component: 'oracle',
    buildDescFilenameFilterRegex: 'buildDesc-sql-sqlserver\\.json$',
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
          `${process.env.CONTINUITY_DB_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'sql-main-oracle',
            filter: 'Sql-Main-Oracle',
          },
        ],
        image: {
          type: 'db',
          db: {
            name: 'oracle',
            versions: [
              '19cee',
            ],
          },
        },
        dependencies: [ 
          ({ db }) => ({
            type: 'image',
            name: 'database',
            reference: `jenkins-deploy.fircosoft.net/continuity/oracle/database-prebuilt:${db.version}`.replace("19cee","19.3.0-ee"),
          }),
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
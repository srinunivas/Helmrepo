export default {
    project: 'Continuity',
    product: 'continuity5',
    projectDirectoryFilter: `${process.env.CONTINUITY_DB_VERSION}.p`,
    asset: 'database',
    component: 'sqlserver',
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
            name: 'sql-main-sqlserver',
            filter: 'Sql-Main-SqlServer',
            expand: true
          },
        ],
        image: {
          type: 'db',
          db: {
            name: 'sqlserver',
            versions: [
              '2019',
            ],
          },
        },
        dependencies: [ 
          ({ db }) => ({
            type: 'image',
            name: 'database',
            reference: `jenkins-deploy.fircosoft.net/third-parties/${db.name}:${db.version}`.replace("2019","2019-GA-ubuntu-16.04"),
            
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
export default {
    project: 'Continuity',
    product: 'continuity5',
    projectDirectoryFilter: `${process.env.FRONTEND_VERSION}.p`,
    asset: 'deployment-console',
    component: 'deployment-console',
    dockerfile: 'Template-sqlserverclient.dockerfile',
    buildDescFilenameFilterRegex: 'buildDesc-Java\\.json$|-platform\\.json$',
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
            name: 'deployment-console',
            filter: 'deployment-console',
          },
        ],
        image: {
          type: 'backend',
          os: {
            name: 'centos',
            versions: [
              '7',
            ],
          },
          jdk: {
            name: 'openjdk',
            versions: [
              '11',
            ],
          },
          odbc: {
            client: {
              name: 'sqlserverclient',
              versions: [
                '17.8.1.1-1',
              ],
            },
          },
          productVersion: {
            name: 'continuity',
            versions: [
              process.env.PRODUCT_VERSION,
            ],  
          },
        },
        dependencies: [
          {
            "type"      : "artifact",
            "name"      : "init",
            "reference" : "dumb-init-1.2.5-linux-x86_64",
            "download"  : true
          },
          ({ os }) => ({
            type: 'image',
            name: 'os',
            reference: `${os.name}:${os.version}`,
          }),
          ({ jdk }) => ({
            "type"      : "artifact",
            "name"      : "mssql-jdbc",
            "reference" : "mssql-jdbc-8.4.1.jre".replace("jre",`jre${jdk.version}`),
            "expand"    : false,
          }),
          {
            "type"      : "artifact",
            "name"      : "workflow",
            "reference" : "continuity5-workflow-" + process.env.FRONTEND_VERSION + "-deployment-console",
            "expand"    : false,
          },
        ],
        additionalTags: [
          ({ artifact, os, jdk, odbc }) => `${artifact.version}-${os.name}${os.version}-${jdk.name}${jdk.version}-${odbc.client.name}${odbc.client.version}`,
        ],
      },
      get develop() {
        return {
          ...this.release,
          generateLatestTags: false,
          branchPrefixFilter: 'develop',
          dependencies: [
            {
              "type"      : "artifact",
              "name"      : "init",
              "reference" : "dumb-init-1.2.5-linux-x86_64",
              "download"  : true
            },
            ({ os }) => ({
              type: 'image',
              name: 'os',
              reference: `${os.name}:${os.version}`,
            }),
            ({ jdk }) => ({
              "type"      : "artifact",
              "name"      : "mssql-jdbc",
              "reference" : "mssql-jdbc-8.4.1.jre".replace("jre",`jre${jdk.version}`),
              "expand"    : false,
            }),
            {
              "type"      : "artifact",
              "name"      : "workflow",
              "reference" : "continuity5-workflow-" + process.env.FRONTEND_VERSION + "-deployment-console-develop",
              "referenceFallback" : "continuity5-workflow-" + process.env.FRONTEND_VERSION + "-deployment-console",
              "expand"    : false,
            },
          ],
            additionalTags: [
            ({ artifact, os, jdk, odbc }) => `${artifact.version}-${os.name}${os.version}-${jdk.name}${jdk.version}-${odbc.client.name}${odbc.client.version}-develop`,
          ],
        };
      },
    },
  }
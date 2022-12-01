export default {
    project: 'Continuity',
    product: 'continuity5',
    projectDirectoryFilter: `${process.env.FRONTEND_VERSION}.p`,
    asset: 'verify-web',
    component: 'verify-web',
    dockerfile: 'Template.dockerfile',
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
            name: 'platform',
            filter: 'platform',
          },
        ],
        image: {
          type: 'was',
          jdk: {
            name: 'openjdk',
            versions: [
              '8',
              '11',
            ],
          },
          was: {
            name: 'tomcat',
            versions: [
              '8.5.57',
              '9.0.37',
            ],
          },
          productVersion: {
            name: 'continuity',
            versions: [
              process.env.PRODUCT_VERSION,
            ],  
          },
        },
        dependencies: [
          ({ jdk, was }) => ({
            type: 'image',
            name: 'tomcat',
            reference: `jenkins-deploy.fircosoft.net/third-parties/${was.name}:${was.version}-jdk${jdk.version}-openjdk-slim`,
          }),
          {
            "type"      : "artifact",
            "name"      : "ojdbc-ojdbc8",
            "reference" : "oracle-ojdbc-ojdbc8-19.3.0.0",
            "expand"    : false,
          },
          ({ jdk }) => ({
            "type"      : "artifact",
            "name"      : "mssql-jdbc",
            "reference" : "mssql-jdbc-8.4.1.jre".replace("jre",`jre${jdk.version}`),
            "expand"    : false,
          }),
        ],
        additionalTags: [
          ({ artifact, jdk, was }) => `${artifact.version}-${was.name}${was.version}-${jdk.name}${jdk.version}`,
        ],
      },
      get develop() {
        return {
          ...this.release,
          generateLatestTags: false,
          branchPrefixFilter: 'develop',
          dependencies: [
            ({ jdk, was }) => ({
              type: 'image',
              name: 'tomcat',
              reference: `jenkins-deploy.fircosoft.net/third-parties/${was.name}:${was.version}-jdk${jdk.version}-openjdk-slim`,
            }),
            {
              "type"      : "artifact",
              "name"      : "ojdbc-ojdbc8",
              "reference" : "oracle-ojdbc-ojdbc8-19.3.0.0",
              "expand"    : false,
            },
            ({ jdk }) => ({
              "type"      : "artifact",
              "name"      : "mssql-jdbc",
              "reference" : "mssql-jdbc-8.4.1.jre".replace("jre",`jre${jdk.version}`),
              "expand"    : false,
            }),
          ],
            additionalTags: [
            ({ artifact, jdk, was }) => `${artifact.version}-${was.name}${was.version}-${jdk.name}${jdk.version}-develop`,
          ],
        };
      },
    },
  }
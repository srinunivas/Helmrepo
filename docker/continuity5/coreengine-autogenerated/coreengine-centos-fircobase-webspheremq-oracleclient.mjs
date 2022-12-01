export default {
  project: 'CoreEngine',
  projectDirectoryFilter: `${process.env.COREENGINE_VERSION}.p`,
  product: 'continuity5',
  asset: 'coreengine',
  component: 'coreengine',
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
        process.env.COREENGINE_VERSION,
      ],
      artifacts: [
        {
          name: 'coreengine',
          filter: 'CoreEngine32',
          expand: true,
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
        fircobase: {
          name: 'fircobase',
          versions: [
            '1.0',
          ],
        },
        mqclient: {
          name: 'webspheremq',
          versions: [
            '9.1.3',
          ],
        },
        odbc: {
          client: {
            name: 'oracleclient',
            versions: [
              '19.6',
            ],
          },
        },
      },
      dependencies: [
        ({ os, fircobase, mqclient, odbc }) => ({
          type: 'image',
          name: 'fircobase',
          reference: `jenkins-deploy.fircosoft.net/shared/${fircobase.name}:${fircobase.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${odbc.client.name}${odbc.client.version}`,
        }),
      ],
      additionalTags: [
        ({ artifact, os, mqclient, odbc }) => `${artifact.version}-${os.name}${os.version}-${odbc.client.name}${odbc.client.version}-${mqclient.name}${mqclient.version}`,
      ],
    },
    get develop() {
      return {
        ...this.release,
        generateLatestTags: false,
        branchPrefixFilter: 'develop',
        additionalTags: [
          ({ artifact, os, mqclient, odbc }) => `${artifact.version}-${os.name}${os.version}-${odbc.client.name}${odbc.client.version}-${mqclient.name}${mqclient.version}-develop`,
        ],
      };
    },
  },
}
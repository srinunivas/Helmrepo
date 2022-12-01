export default {
  project: 'TrustBatch',
  product: 'Trust',
  asset: 'Batch',
  component: 'Linux',
  buildDescFilenameFilterRegex: 'buildDesc-Linux-i686\\.json$',
  environments: {
    release: {
      generateLatestTags: true,
      branchPrefixFilter: 'release',
      artifacts: [
        {
          name: 'Batch',
          filter: 'TrustBatch-.*.tar.gz$',
        },
      ],
      image: {
        type: 'backend',
        os: {
          name: 'centos',
          versions: [
            7,
          ],
        },
        odbc: {
          manager: {
            name: 'unixodbc',
            versions: [
              '2.3.1'
            ]
          },
          client: {
            name: 'oracle',
            versions: [
              12.1,
              19.6,
            ],
          },
        },
        labels: {
          'maintainer': 'Sébastien Demanou <sebastien.demanou@accuity.com>',
          'com.accuity.team': 'Trust',
          'com.accuity.project-name': 'TRUST',
          'com.accuity.project-url': 'http://jira.fircosoft.net/projects/TRUST',
        },
      },
      dependencies: [
        ({ os, odbc }) => ({
          type: 'image',
          name: 'unixodbc',
          reference: `jenkins-deploy.fircosoft.net/third-parties/${odbc.manager.name}:${odbc.manager.version}-${os.name}${os.version}-${odbc.client.name}${odbc.client.version}`,
        }),
      ],
      excludedVersions: [
        '4.5.5.3$',
        '4.5.3.6_BETA',
        '4.6.x',
        '4.6.1.2$',
        '4.6.1.3$',
        '4.6.1.4$',
        '4.6.1.5_BETA$',
        '4.6.1.5$',
        '4.6.2.0$',
        '4.6.2.2$',
        '4.6.2.3$',
        '4.6.2.4$',
        '4.6.3.0$',
        '4.6.3.1$',
        '4.6.3.2$',
        '4.6.3.3$',
        '4.6.3.5_BETA3$',
        '4.6.3.5_BETA$',
        '4.6.3.5$',
        '4.6.3.6_BETA$',
        '4.6.3.6$',
        '4.6.3.7$',
        '4.6.3.8$',
        '4.6.4.0$',
        '4.6.4.1$',
        '4.6.4.2$',
        '4.6.4.10-SNAPSHOT',
        '5.0.0.0',
        '5.0.0.0_BETA_140',
        '5.1.1.0_BETA',
      ],
    },
    get develop() {
      return {
        ...this.release,
        generateLatestTags: false,
        branchPrefixFilter: 'develop',
        onlyVersions: [
          '.+-SNAPSHOT',
        ],
      };
    },
  },
};
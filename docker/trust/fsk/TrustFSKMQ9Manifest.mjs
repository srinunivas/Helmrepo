export default {
  project: 'TrustFSK',
  product: 'Trust',
  asset: 'FSK',
  component: 'Linux',
  dockerfile: 'TemplateMQ9.dockerfile',
  buildDescFilenameFilterRegex: 'buildDesc-Linux-i686\.json$',
  environments: {
    release: {
      autoPush: true,
      autoBuild: true,
      generateLatestTags: true,
      excludedVersions: [
        '4.6.1.5',
        '4.6.1.6',
        '4.6.4.1',
        '4.6.4.3',
        '4.6.4.4',
        '4.6.4.5',
        '4.6.4.6',
        '4.6.0.0',
        '4.6.1.2',
        '4.6.1.3',
        '4.6.1.4',
        '4.6.1.5_',
        '4.6.1.5_BETA',
        '4.6.2.0',
        '4.6.3.0',
        '4.6.3.1',
        '4.6.3.2',
        '4.6.3.3',
        '4.6.3.5',
        '4.6.4.0',
        '5.0.0.0',
      ],
      branchPrefixFilter: 'release',
      artifacts: [
        {
          name: 'FSK',
          filter: 'TrustFSK-.*.tar.gz$',
          exclusionPatterns: [
            '4.6.4.7.p0-release-4.7.x',
          ],
        },
      ],
      image: {
        type: 'backend',
        os: {
          name: 'centos',
          versions: [
            7
          ],
        },
        odbc: {
          manager: {
            name: 'unixodbc',
            versions: [
              '2.3.1',
            ],
          },
          client: {
            name: 'oracle',
            versions: [
              '12.1',
            ],
          },
        },
        mqclient: {
          name: 'webspheremq',
          versions: [
            '9.0.0.4',
            '9.2.0.1',
          ],
        },
        labels: {
          'maintainer': 'Sébastien Demanou <sebastien.demanou@accuity.com>',
          'com.accuity.team': 'Trust',
          'com.accuity.project-name': 'TRUST',
          'com.accuity.project-url': 'http://jira.fircosoft.net/projects/TRUST',
        },
      },
      dependencies: [
        {
          type: 'image',
          name: 'unixodbc',
          reference: 'jenkins-deploy.fircosoft.net/third-parties/unixodbc:2.3.1-centos7-oracle12.1',
        },
        ({ mqclient: { version } }) => ({
          type: 'artifact',
          name: 'mqclient',
          reference: `ibm-mq-client-${version}.x86_64`,
          expand: false,
        }),
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
        excludedVersions: [
          ...this.release.excludedVersions,
          '4.6.1.6-SNAPSHOT',
        ],
      };
    },
  },
};

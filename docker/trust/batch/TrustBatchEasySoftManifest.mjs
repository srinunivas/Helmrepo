import TrustBatchUnixODBCManifest from './TrustBatchUnixODBCManifest.mjs';

export default {
  ...TrustBatchUnixODBCManifest,
  environments: {
    release: {
      ...TrustBatchUnixODBCManifest.environments.release,
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
            name: 'easysoft',
            versions: [
              '3.8.0',
            ],
          },
          client: {
            name: 'oracle',
            versions: [
              12.1,
              19.6,
            ],
          },
        },
        labels: TrustBatchUnixODBCManifest.environments.release.image.labels,
      },
      excludedVersions: [
        '4.5.5.3$',
        '4.5.3.6_BETA',
        '4.6.x',
      ],
    },
    get develop() {
      return {
        ...this.release,
        generateLatestTags: false,
        branchPrefixFilter: 'develop',
        onlyVersions: [
          '.+-SNAPSHOT'
        ],
      };
    },
  },
};

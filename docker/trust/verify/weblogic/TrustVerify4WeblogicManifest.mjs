import TrustVerify5WeblogicManifest from './TrustVerify5WeblogicManifest.mjs';

export default {
  ...TrustVerify5WeblogicManifest,
  project: 'TrustFront',
  environments: {
    release: {
      ...TrustVerify5WeblogicManifest.environments.release,
      excludedVersions: [
        '4.5.',
      ],
    },
    get develop() {
      return {
        ...this.release,
        generateLatestTags: false,
        branchPrefixFilter: 'develop',
        onlyVersions: [
          ".+-SNAPSHOT",
        ],
      };
    },
  },
}

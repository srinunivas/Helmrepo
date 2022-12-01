import TrustVerify5WebsphereManifest from './TrustVerify5WebsphereManifest.mjs';

export default {
  ...TrustVerify5WebsphereManifest,
  project: 'TrustFront',
  environments: {
    release: {
      ...TrustVerify5WebsphereManifest.environments.release,
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

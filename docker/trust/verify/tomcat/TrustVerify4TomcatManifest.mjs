import TrustVerify5Manifest from './TrustVerify5TomcatManifest.mjs';

export default {
  ...TrustVerify5Manifest,
  project: 'TrustFront',
  environments: {
    ...TrustVerify5Manifest.environments,
    release: {
      ...TrustVerify5Manifest.environments.release,
      excludedVersions: [
        '4.5.',
      ],
    },
  },
}

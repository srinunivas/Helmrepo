import TrustVerify5TomcatManifest from '../tomcat/TrustVerify5TomcatManifest.mjs';

export default {
  ...TrustVerify5TomcatManifest,
  environments: {
    release: {
      ...TrustVerify5TomcatManifest.environments.release,
      image: {
        ...TrustVerify5TomcatManifest.environments.release.image,
        jdk: {
          name: 'ibmjdk',
          versions: [
            '8',
          ],
        },
        was: {
          name: 'websphere',
          versions: [
            '9.0.5.6',
          ],
        },
      },
      dependencies: [
        ({ was }) => ({
          type: 'image',
          name: 'websphere',
          reference: `jenkins-deploy.fircosoft.net/third-parties/ibmcom/websphere-traditional:${was.version}`,
        }),
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

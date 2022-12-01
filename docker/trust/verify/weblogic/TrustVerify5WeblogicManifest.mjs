import TrustVerify5TomcatManifest from '../tomcat/TrustVerify5TomcatManifest.mjs';

export default {
  ...TrustVerify5TomcatManifest,
  environments: {
    release: {
      ...TrustVerify5TomcatManifest.environments.release,
      image: {
        ...TrustVerify5TomcatManifest.environments.release.image,
        jdk: {
          name: 'jdk',
          versions: [
            '8',
          ],
        },
        was: {
          name: 'weblogic',
          versions: [
            '12.2.1.4',
          ],
        },
      },
      dependencies: [
        ({ was }) => ({
          type: 'image',
          name: 'weblogic',
          reference: `jenkins-deploy.fircosoft.net/third-parties/docker.io/store/oracle/weblogic:${was.version}`,
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
      };
    },
  },
}

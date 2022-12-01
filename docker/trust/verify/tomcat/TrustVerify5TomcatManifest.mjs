export default {
  project: 'TrustFrontV5',
  product: 'Trust',
  asset: 'Verify',
  component: 'WAR',
  buildDescFilenameFilterRegex: 'buildDesc-Java\\.json$',
  environments: {
    release: {
      generateLatestTags: true,
      branchPrefixFilter: 'release',
      artifacts: [
        {
          name: 'Verify',
          filter: '.war$',
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
        labels: {
          'maintainer': 'Sébastien Demanou <sebastien.demanou@accuity.com>',
          'com.accuity.team': 'Trust',
          'com.accuity.project-name': 'TRUST',
          'com.accuity.project-url': 'http://jira.fircosoft.net/projects/TRUST'
        },
      },
      dependencies: [
        ({ jdk, was }) => ({
          type: 'image',
          name: 'tomcat',
          reference: `jenkins-deploy.fircosoft.net/third-parties/${was.name}:${was.version}-jdk${jdk.version}-openjdk-slim`,
        }),
      ],
      excludedVersions: [
        '5.0.0.0-SNAPSHOT',
        '5.1.0.3-SNAPSHOT',
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

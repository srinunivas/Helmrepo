export default {
  project: 'Continuity-CEBACK',
  product: 'continuity6',
  asset: 'decisionreapplication',
  component: 'Linux',
  buildDescFilenameFilterRegex: 'buildDesc-Linux-i686\\.json$',
  environments: {
    release: {
      generateLatestTags: true,
      branchPrefixFilter: 'release',
      autoPush: true,
      labels: {
        'maintainer': 'BOUABID Mohammed <mohammed.bouabid@accuity.com>',
        'com.accuity.team': 'CONTINUITY',
        'com.accuity.project-name': 'CONTINUITY',
        'com.accuity.project-url': 'http://jira.fircosoft.net/projects/CONTINUITY'
      },
      artifacts: [
        {
          name: 'DecisionReapplication',
          filter: 'ContinuityDecisionReapplication',
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
        coreengine: {
          versions: [
            '6.0.0.0',
            '6.1.0.0',
            '6.2.0.0',
            '6.2.1.0',
          ]
        }
      },
      dependencies: [
        ({ coreengine }) => ({
          type: 'artifact',
          name: 'coreengine',
          reference: `third-parties-coreengine-${coreengine.version}-linux`,
          expand: false,
        })
      ],
    },
  },
}
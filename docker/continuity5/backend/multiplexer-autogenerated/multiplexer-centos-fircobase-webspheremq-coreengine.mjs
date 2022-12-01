export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.MULTIPLEXER_VERSION}.p`,
    product: 'continuity5',
    asset: 'multiplexer',
    component: 'multiplexer',
    buildDescFilenameFilterRegex: 'buildDesc-Linux-i686\\.json$',
    environments: {
      release: {
        generateLatestTags: false,
        branchPrefixFilter: 'release',
        autoPush: true,
        labels: {
          'maintainer': 'MESSEGUE Emmanuel <emmanuel.messegue@accuity.com>',
          'com.accuity.team': 'CONTINUITY',
          'com.accuity.project-name': 'CONTINUITY',
          'com.accuity.project-url': 'http://jira.fircosoft.net/projects/CONTINUITY'
        },
        onlyVersions: [
          `${process.env.MULTIPLEXER_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'multiplexer',
            filter: 'ContinuityMultiplexer',
            expand: true
          },
        ],
        image: {
          type: 'backend',
          os: {
            name: 'centos',
            versions: [
              '7',
            ],
          },
          fircobase: {
            name: 'fircobase',
            versions: [
              '1.0',
            ],
          },
          mqclient: {
            name: 'webspheremq',
            versions: [
              '9.1.3',
            ],
          },
          coreengine: {
            name: 'coreengine',
            versions: 
              process.env.CORENGINE_VERSIONS.split(','),
          },
          productVersion: {
            name: 'continuity',
            versions: [
              process.env.PRODUCT_VERSION,
            ],  
          },
        },
        dependencies: [
          ({ os, fircobase, mqclient, coreengine }) => ({
            type: 'image',
            name: 'coreengineBase',
            reference: `jenkins-deploy.fircosoft.net/continuity5/${coreengine.name}:${coreengine.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${fircobase.name}${fircobase.version}`,
            referenceFallback: `jenkins-deploy.fircosoft.net/continuity5/${coreengine.name}:${coreengine.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${fircobase.name}${fircobase.version}-develop`,
          }),
          {
            "type"      : "artifact",
            "name"      : "fircocontractmapper",
            "reference" : "continuity5-fircocontractmapper-" + process.env.FIRCOCONTRACTMAPPER_VERSION + "-fircocontractmapper",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "mappinghttpstatus",
            "reference" : "continuity5-mappinghttpstatus-" + process.env.MAPPINGHTTPSTATUS_VERSION + "-mappinghttpstatus",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "jsonutilities",
            "reference" : "continuity5-jsonutilities-" + process.env.JSONUTILITIES_VERSION + "-jsonutilities",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "mappingcasemanagerapi",
            "reference" : "continuity5-mappingcasemanagerapi-" + process.env.MAPPINGCASEMANAGERAPI_VERSION + "-mappingcasemanagerapi",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "mappingxmluniversal",
            "reference" : "continuity5-mappingxmluniversal-" + process.env.MAPPINGXMLUNIVERSAL_VERSION + "-mappingxmluniversal",
            "expand"    : true,
          },
        ],
        additionalTags: [
          ({ artifact, os, mqclient, coreengine }) => `${artifact.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${coreengine.name}${coreengine.version}`,
          ({ artifact, os, mqclient, coreengine, productVersion }) => `${artifact.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${coreengine.name}${coreengine.version}-${productVersion.name}${productVersion.version}`,
        ],
            },
      get develop() {
        return {
          ...this.release,
          generateLatestTags: false,
          branchPrefixFilter: 'develop',
          dependencies: [
            ({ os, fircobase, mqclient, coreengine }) => ({
              type: 'image',
              name: 'coreengineBase',
              reference: `jenkins-deploy.fircosoft.net/continuity5/${coreengine.name}:${coreengine.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${fircobase.name}${fircobase.version}-develop`,
              referenceFallback: `jenkins-deploy.fircosoft.net/continuity5/${coreengine.name}:${coreengine.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${fircobase.name}${fircobase.version}`,
            }),
            {
              "type"      : "artifact",
              "name"      : "fircocontractmapper",
              "reference" : "continuity5-fircocontractmapper-" + process.env.FIRCOCONTRACTMAPPER_VERSION + "-fircocontractmapper-develop",
              "referenceFallback" : "continuity5-fircocontractmapper-" + process.env.FIRCOCONTRACTMAPPER_VERSION + "-fircocontractmapper",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "mappinghttpstatus",
              "reference" : "continuity5-mappinghttpstatus-" + process.env.MAPPINGHTTPSTATUS_VERSION + "-mappinghttpstatus-develop",
              "referenceFallback" : "continuity5-mappinghttpstatus-" + process.env.MAPPINGHTTPSTATUS_VERSION + "-mappinghttpstatus",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "jsonutilities",
              "reference" : "continuity5-jsonutilities-" + process.env.JSONUTILITIES_VERSION + "-jsonutilities-develop",
              "referenceFallback" : "continuity5-jsonutilities-" + process.env.JSONUTILITIES_VERSION + "-jsonutilities",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "mappingcasemanagerapi",
              "reference" : "continuity5-mappingcasemanagerapi-" + process.env.MAPPINGCASEMANAGERAPI_VERSION + "-mappingcasemanagerapi-develop",
              "referenceFallback" : "continuity5-mappingcasemanagerapi-" + process.env.MAPPINGCASEMANAGERAPI_VERSION + "-mappingcasemanagerapi",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "mappingxmluniversal",
              "reference" : "continuity5-mappingxmluniversal-" + process.env.MAPPINGXMLUNIVERSAL_VERSION + "-mappingxmluniversal-develop",
              "referenceFallback" : "continuity5-mappingxmluniversal-" + process.env.MAPPINGXMLUNIVERSAL_VERSION + "-mappingxmluniversal",
              "expand"    : true,
            },
          ],
          additionalTags: [
            ({ artifact, os, mqclient, coreengine }) => `${artifact.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${coreengine.name}${coreengine.version}-develop`,
            ({ artifact, os, mqclient, coreengine, productVersion }) => `${artifact.version}-${os.name}${os.version}-${mqclient.name}${mqclient.version}-${coreengine.name}${coreengine.version}-${productVersion.name}${productVersion.version}-develop`,
          ],
        };
      },
    },
  }
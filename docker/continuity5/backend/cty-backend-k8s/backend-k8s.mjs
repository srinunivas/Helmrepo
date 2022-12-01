export default {
    project: 'Continuity',
    projectDirectoryFilter: `${process.env.PRODUCT_VERSION}.p`,
    product: 'continuity5',
    asset: 'backend-k8s',
    component: 'backend-k8s',
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
          `${process.env.PRODUCT_VERSION}$`,
        ],
        artifacts: [
          {
            name: 'backend-k8s',
            filter: 'ContinuityDBClient|ContinuityRequester|ContinuityMultiplexer|ContinuityPairing|ContinuityStripping|ContinuityDBTools|MappingContinuityCaseManagerAPI|FircoContractMapper|MappingContinuityHTTPStatus|MappingXMLUniversal|ContinuityJSONUtilities',
            expand: false,
            comment1: "dummy artefact 'backend-k8s' will be generated but not used in Template.dockerfile",
            comment2: "filter is used to generate the imageData file if at least one of these module is found with the expected PRODUCT_VERSION"
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
          coreengine: {
            name: 'coreengine',
            versions: 
              process.env.CORENGINE_VERSIONS.split(','),
          },
        },
        dependencies: [
          {
            "type"      : "artifact",
            "name"      : "init",
            "reference" : "dumb-init-1.2.5-linux-x86_64",
            "download"  : true
          },
          ({ coreengine }) => ({
            "type": 'artifact',
            "name": 'coreengine',
            "reference": `continuity5-coreengine-${coreengine.version}-coreengine`,
            "expand"    : true
          }),
          {
            "type"      : "artifact",
            "name"      : "upgrade-dbclient",
            "reference" : "continuity5-upgrade-dbclient-" + process.env.DBCLIENT_VERSION + "-dbclient",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-requester",
            "reference" : "continuity5-upgrade-requester-" + process.env.REQUESTER_VERSION + "-requester",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-multiplexer",
            "reference" : "continuity5-upgrade-multiplexer-" + process.env.MULTIPLEXER_VERSION + "-multiplexer",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-pairing",
            "reference" : "continuity5-upgrade-pairing-" + process.env.PAIRING_VERSION + "-pairing",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-stripping",
            "reference" : "continuity5-upgrade-stripping-" + process.env.STRIPPING_VERSION + "-stripping",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-advancedreporting",
            "reference" : "continuity5-upgrade-advancedreporting-" + process.env.ADVANCEDREPORTING_VERSION + "-advancedreporting",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-dbtools",
            "reference" : "continuity5-upgrade-dbtools-" + process.env.DBTOOLS_VERSION + "-dbtools",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-drchecksummigrator",
            "reference" : "continuity5-upgrade-drchecksummigrator-" + process.env.DRCHECKSUMMIGRATOR_VERSION + "-drchecksummigrator",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-predictionintegrator",
            "reference" : "continuity5-upgrade-predictionintegrator-" + process.env.PREDICTIONINTEGRATOR_VERSION + "-predictionintegrator",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-fircocontractmapper",
            "reference" : "continuity5-upgrade-fircocontractmapper-" + process.env.FIRCOCONTRACTMAPPER_VERSION + "-fircocontractmapper",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-jsonutilities",
            "reference" : "continuity5-upgrade-jsonutilities-" + process.env.JSONUTILITIES_VERSION + "-jsonutilities",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-mappingcasemanagerapi",
            "reference" : "continuity5-upgrade-mappingcasemanagerapi-" + process.env.MAPPINGCASEMANAGERAPI_VERSION + "-mappingcasemanagerapi",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-mappinghttpstatus",
            "reference" : "continuity5-upgrade-mappinghttpstatus-" + process.env.MAPPINGHTTPSTATUS_VERSION + "-mappinghttpstatus",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-mappingxmluniversal",
            "reference" : "continuity5-upgrade-mappingxmluniversal-" + process.env.MAPPINGXMLUNIVERSAL_VERSION + "-mappingxmluniversal",
            "expand"    : true,
          },
          {
            "type"      : "artifact",
            "name"      : "upgrade-archiving",
            "reference" : "continuity5-upgrade-archiving-" + process.env.ARCHIVING_VERSION + "-archiving",
            "expand"    : true,
          },
        ],
      },
      get develop() {
        return {
          ...this.release,
          generateLatestTags: false,
          branchPrefixFilter: 'develop',
          dependencies: [
            {
              "type"      : "artifact",
              "name"      : "init",
              "reference" : "dumb-init-1.2.5-linux-x86_64",
              "download"  : true
            },
            ({ coreengine }) => ({
              "type": 'artifact',
              "name": 'coreengine',
              "reference": `continuity5-coreengine-${coreengine.version}-coreengine-develop`,
              "referenceFallback": `continuity5-coreengine-${coreengine.version}-coreengine`,
              "expand"    : true
            }),
            {
              "type"      : "artifact",
              "name"      : "upgrade-dbclient",
              "reference" : "continuity5-upgrade-dbclient-" + process.env.DBCLIENT_VERSION + "-dbclient-develop",
              "referenceFallback" : "continuity5-upgrade-dbclient-" + process.env.DBCLIENT_VERSION + "-dbclient",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-requester",
              "reference" : "continuity5-upgrade-requester-" + process.env.REQUESTER_VERSION + "-requester-develop",
              "referenceFallback" : "continuity5-upgrade-requester-" + process.env.REQUESTER_VERSION + "-requester",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-multiplexer",
              "reference" : "continuity5-upgrade-multiplexer-" + process.env.MULTIPLEXER_VERSION + "-multiplexer-develop",
              "referenceFallback" : "continuity5-upgrade-multiplexer-" + process.env.MULTIPLEXER_VERSION + "-multiplexer",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-pairing",
              "reference" : "continuity5-upgrade-pairing-" + process.env.PAIRING_VERSION + "-pairing-develop",
              "referenceFallback" : "continuity5-upgrade-pairing-" + process.env.PAIRING_VERSION + "-pairing",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-stripping",
              "reference" : "continuity5-upgrade-stripping-" + process.env.STRIPPING_VERSION + "-stripping-develop",
              "referenceFallback" : "continuity5-upgrade-stripping-" + process.env.STRIPPING_VERSION + "-stripping",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-advancedreporting",
              "reference" : "continuity5-upgrade-advancedreporting-" + process.env.ADVANCEDREPORTING_VERSION + "-advancedreporting-develop",
              "referenceFallback" : "continuity5-upgrade-advancedreporting-" + process.env.ADVANCEDREPORTING_VERSION + "-advancedreporting",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-dbtools",
              "reference" : "continuity5-upgrade-dbtools-" + process.env.DBTOOLS_VERSION + "-dbtools-develop",
              "referenceFallback" : "continuity5-upgrade-dbtools-" + process.env.DBTOOLS_VERSION + "-dbtools",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-drchecksummigrator",
              "reference" : "continuity5-upgrade-drchecksummigrator-" + process.env.DRCHECKSUMMIGRATOR_VERSION + "-drchecksummigrator-develop",
              "referenceFallback" : "continuity5-upgrade-drchecksummigrator-" + process.env.DRCHECKSUMMIGRATOR_VERSION + "-drchecksummigrator",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-predictionintegrator",
              "reference" : "continuity5-upgrade-predictionintegrator-" + process.env.PREDICTIONINTEGRATOR_VERSION + "-predictionintegrator-develop",
              "referenceFallback" : "continuity5-upgrade-predictionintegrator-" + process.env.PREDICTIONINTEGRATOR_VERSION + "-predictionintegrator",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-fircocontractmapper",
              "reference" : "continuity5-upgrade-fircocontractmapper-" + process.env.FIRCOCONTRACTMAPPER_VERSION + "-fircocontractmapper-develop",
              "referenceFallback" : "continuity5-upgrade-fircocontractmapper-" + process.env.FIRCOCONTRACTMAPPER_VERSION + "-fircocontractmapper",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-jsonutilities",
              "reference" : "continuity5-upgrade-jsonutilities-" + process.env.JSONUTILITIES_VERSION + "-jsonutilities-develop",
              "referenceFallback" : "continuity5-upgrade-jsonutilities-" + process.env.JSONUTILITIES_VERSION + "-jsonutilities",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-mappingcasemanagerapi",
              "reference" : "continuity5-upgrade-mappingcasemanagerapi-" + process.env.MAPPINGCASEMANAGERAPI_VERSION + "-mappingcasemanagerapi-develop",
              "referenceFallback" : "continuity5-upgrade-mappingcasemanagerapi-" + process.env.MAPPINGCASEMANAGERAPI_VERSION + "-mappingcasemanagerapi",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-mappinghttpstatus",
              "reference" : "continuity5-upgrade-mappinghttpstatus-" + process.env.MAPPINGHTTPSTATUS_VERSION + "-mappinghttpstatus-develop",
              "referenceFallback" : "continuity5-upgrade-mappinghttpstatus-" + process.env.MAPPINGHTTPSTATUS_VERSION + "-mappinghttpstatus",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-mappingxmluniversal",
              "reference" : "continuity5-upgrade-mappingxmluniversal-" + process.env.MAPPINGXMLUNIVERSAL_VERSION + "-mappingxmluniversal-develop",
              "referenceFallback" : "continuity5-upgrade-mappingxmluniversal-" + process.env.MAPPINGXMLUNIVERSAL_VERSION + "-mappingxmluniversal",
              "expand"    : true,
            },
            {
              "type"      : "artifact",
              "name"      : "upgrade-archiving",
              "reference" : "continuity5-upgrade-archiving-" + process.env.ARCHIVING_VERSION + "-archiving-develop",
              "referenceFallback" : "continuity5-upgrade-archiving-" + process.env.ARCHIVING_VERSION + "-archiving",
              "expand"    : true,
            },
          ],
        };
      },
    },
  }
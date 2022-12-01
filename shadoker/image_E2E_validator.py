import logging

from shadoker.package_manager import Image

TRAITS_PER_PRODUCT = {
    'continuity5': {
        'verify-web' :               [      'webServer', 'java'                                                     ],
#        'coreengine' :               ['os',                                                 'odbcClient', 'mqClient'],
        'coreengine' :               ['os'                                                                          ],
#        'multiplexer' :              ['os',                                                               'mqClient'],
        'multiplexer' :              ['os'                                                                          ],
#        'requester' :                ['os',                                                               'mqClient'],
        'requester' :                ['os'                                                                          ],
        'webservice-connector' :     ['os'                                                                          ],
        'stripping' :                ['os'                                                                          ],
        'pairing' :                  ['os'                                                                          ],
        'prediction-integrator' :    ['os'                                                                          ],
        'dbclient' :                 ['os',                                                 'odbcClient'            ],
        'dbtools' :                  ['os',                                                 'odbcClient'            ],
        'archiving' :                ['os',                                                 'odbcClient'            ],
      # 'advanced-reporting' :       ['os',                                                 'odbcClient'            ],
        'case-manager-api' :         ['os',                                                 'odbcClient'            ],
        'dr-checksum-migrator' :     ['os',                                                 'odbcClient'            ],
        'workflow-accelerator' :     ['os'                                                                          ],
        'hpr' :                      ['os'                                                                          ],
        'database' :                 [                           'database'                                         ],
        'advanced-reporting' :       [                           'database'                                         ],
        'proxy' :                    ['os'                                                                          ],
        'json-utilities' :           ['os'                                                                          ],
        'mapping-case-manager-api' : ['os'                                                                          ],
        'mapping-http-status' :      ['os'                                                                          ],
        'mapping-xml-universal' :    ['os'                                                                          ]
    },
    'trust': {
        'verify':    [      'webServer', 'java'                                                     ],
        'batch':     ['os',                                  'odbcManager', 'odbcClient'            ],
        'fsk':       ['os',                                  'odbcManager', 'odbcClient', 'mqClient'],
        'cmapi':     ['os',                                  'odbcManager', 'odbcClient'            ],
        'fol':       ['os',                                                                         ],
        'database':  [                           'database'                                         ],
    },
    'filter': {
        'filter-engine': ['os'],
        'unifilter':     ['os']
    },
    'utilities': {
        'fum':           ['os',             'odbcClient'],
        'fmm':           ['os',             'odbcClient'],
        'fmm-javabatch': ['os',             'odbcClient'],
        'fml':           ['os',             'odbcClient'],
        'database-fum':  [      'database'              ],
        'database-fmm':  [      'database'              ],
        'fum-database':  [      'database'              ],
        'fmm-database':  [      'database'              ]
    },
    'liveservices-shared': {
        'admin-web': [],
        'admin':     [],
        'audit':     [],
        'discovery': [],
        'messaging': [],
        'reporting': []
    },
    'liveservices-soc': {
        'web':               [],
        'soc-api':           [],
        'global-agent':      [],
        'local-agent':       [],
        'filter-controller': [],
        'ia-controller':     []
    },
    'liveservices-wlm': {
        'web':     [],
        'wlm-api': []
    },
    'liveservices-kyf': {
        'web':         [],
        'core-api':    [],
        'list-api':    [],
        'config-api':  [],
        'project-api': []
    },
    'shared': {
    },
    'erf': {
        'samconsole': ['os'],
        'samnet':     ['os']
    }
}
TRAITS_PER_PRODUCT['continuity6'] = TRAITS_PER_PRODUCT['continuity5']

def validateE2E(image: Image, logger: logging.Logger) -> bool:
    """Validate the specified Image traits are compliant with E2E-121 convention.
    """
    msg = f'Checking {image} for E2E-121:'
    if not isinstance(logger, logging.Logger):
        raise Exception('Image validation requires a logger')
    if not isinstance(image, Image):
        logger.critical('Bad parameter, specified image has not the type Image')
        raise Exception('Bad parameter, specified image has not the type Image')
    if not image.hasSchema('e2e-121'):
        msg += ' does not follow E2E-121 schema, skipping validation'
        logger.info(f'{image} does not follow E2E-121 schema, skipping validation')
        return 'ignore', msg
    product = image.product.lower()
    if not product in TRAITS_PER_PRODUCT:
        msg += f' product "{product}" not registered'
        logger.error(f'{image} has product "{product}" which is not registered for E2E-121')
        return False, msg
    asset = image.asset.lower()
    if not asset in TRAITS_PER_PRODUCT[product]:
        msg += f' asset "{asset}" not registered, skipping further validation'
        logger.warn(f'{image} has asset "{asset}" which not registered for product "{product}" for E2E-121')
        return 'skip', msg

    valid = True
    msgParts = []
    image_thirdParties = image.thirdParties
    valid_thirdParties = TRAITS_PER_PRODUCT[product][asset]
    for trait in valid_thirdParties:
        if trait == 'os':
            os = image.getProperty('os')
            if not os:
                valid = False
                msgParts.append(' missing "os" property')
                logger.warn(f'{image} is missing "os" property')
            elif not os.islower():
                valid = False
                msgParts.append(f' "os" property is not in lower case')
                logger.warn(f'{image} has "{os}" property which is not lower case')
        elif not trait in image_thirdParties:
            valid = False
            msgParts.append(f' missing "{trait}" third-party')
            logger.warn(f'{image} is missing "{trait}" third-party')
    for trait in image_thirdParties:
        trait_value = image_thirdParties[trait]
        if not trait_value.islower():
            valid = False
            msgParts.append(f' "{trait}" third-party is not in lower case')
            logger.warn(f'{image} has "{trait}" third-party which is not lower case')
        if not trait in valid_thirdParties:
            msgParts.append(f' extra "{trait}" third-party')
            logger.warn(f'{image} has extra "{trait}" third-party')
    if valid:
        msg += f' {product}-{asset}-{image.version} is compliant with E2E-121 schema'
    else:
        msg += ','.join(msgParts)
    return valid, msg

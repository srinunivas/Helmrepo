import sys
import logging
from logging.config import dictConfig

logging_config = dict(
    version=1,
    formatters={
        'verbose': {
            'format': ("[%(asctime)s] %(levelname)s "
                       "[%(name)s:%(lineno)s] %(message)s"),
            'datefmt': "%d/%b/%Y %H:%M:%S",
        },
        'simple': {
            'format': '%(levelname)s %(message)s',
        },
        'message': {
            'format': '%(message)s',
        }
    },
    handlers={
        # 'api-logger': {'class': 'logging.handlers.RotatingFileHandler',
        #                    'formatter': 'verbose',
        #                    'level': logging.DEBUG,
        #                    'filename': 'logs/api.log',
        #                    'maxBytes': 52428800,
        #                    'backupCount': 7},
        # 'batch-process-logger': {'class': 'logging.handlers.RotatingFileHandler',
        #                      'formatter': 'verbose',
        #                      'level': logging.DEBUG,
        #                      'filename': 'logs/batch.log',
        #                      'maxBytes': 52428800,
        #                      'backupCount': 7},
        'console': {
            'class': 'logging.StreamHandler',
            'level': 'DEBUG',
            'formatter': 'simple',
            'stream': sys.stdout,
        },
        'null': {
            'class': 'logging.NullHandler'
        }
    },
    loggers={
        'command': {
            'handlers': [],
            'level': logging.INFO
        }
    }
)

dictConfig(logging_config)
command_logger = logging.getLogger('command')
command_logger.propagate = False
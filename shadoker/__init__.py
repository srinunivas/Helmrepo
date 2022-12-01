import os
import shutil

__all__ = [
    "archiver",
    "build_result",
    "change_set",
    "chart_manager",
    "image_E2E_validator",
    "item_status",
    "manifest_manager",
    "object_matcher",
    "package_manager",
    "report_helpers",
    "shadoker_globals",
    "template_renderer"
]

DOCKER_PATH = shutil.which('docker')
if DOCKER_PATH is None:
    raise ImportError(f'Cannot find docker executable')

GIT_PATH = shutil.which('git')
if GIT_PATH is None:
    raise ImportError(f'Cannot find git executable')

if 'GRYPE_EXECUTABLE' in os.environ:
    GRYPE_PATH = os.environ['GRYPE_EXECUTABLE']
    if not os.access(GRYPE_PATH, os.X_OK):
        GRYPE_PATH = None
else:
    GRYPE_PATH = shutil.which('grype')

if 'SYFT_EXECUTABLE' in os.environ:
    SYFT_PATH = os.environ['SYFT_EXECUTABLE']
    if not os.access(SYFT_PATH, os.X_OK):
        SYFT_PATH = None
else:
    SYFT_PATH = shutil.which('syft')

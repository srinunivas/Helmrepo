import pytest
from shadoker.package_manager import PackageManager

def test_classes():
    # Checks that package_manager.py is well-formed
    with pytest.raises(Exception):
        PackageManager(None, None, None)
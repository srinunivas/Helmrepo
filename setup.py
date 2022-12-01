from setuptools import setup (
    name = 'shadoker',
    version = '0.1.0',
    packages = ['shadoker'],
    entry_points = {
        'console_scripts': [
            'shadoker = shadoker.__main__:main'
        ]
    })
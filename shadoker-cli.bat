@SET GODEBUG="x509ignoreCN=0"
@SET DOCKER_BUILDKIT=1
@SET PYTHONHASHSEED=0
@SET PYTHONPATH=%~dp0

@python shadoker\__main__.py %*
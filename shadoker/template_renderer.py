import copy, orjson, logging, os, pystache
from pathlib import Path
from typing import List

from shadoker import shadoker_globals

logger = logging.getLogger()

class TemplateRenderer:
    def __init__(self, config_file: str = None, parent: 'TemplateRenderer' = None):
        """ Creates a new TemplateRenderer instance
        Parameters
        ----------
        config_file : str
            An optional JSON configuration file with the properties to use in this TemplateRenderer.
            IF this file contains a top level "properties" property, this one will be used, otherwise the full root object is used.
        parent : TemplateRenderer
            An optional parent TemplateRenderer for this instance.
            All properties will be inherited, but could be overriden.
            Parent's properties can also be used as template variable directly in this instance properties.
        """
        if (parent):
            self.template_data = copy.deepcopy(parent.properties)
        else:
            self.template_data = dict()
        if (config_file):
            if (not Path(config_file).exists()):
                logger.debug('Instanciating TemplateRenderer from missing configuration file "%s"' % config_file)
            else:
                try:
                    with open(config_file) as f:
                        config_text = f.read().strip()
                        if (len(config_text) == 0):
                            logger.warn('Instanciating TemplateRenderer from empty configuration file "%s"' % config_file)
                        config_properties = orjson.loads(config_text)
                        if (not isinstance(config_properties, dict)):
                            raise Exception('Cannot instanciate TemplateRenderer with configuration file "%s" because this is not a valid JSON object' % config_file)
                        if ('properties' in config_properties):
                            self.addProperties(config_properties['properties'])
                        else:
                            self.addProperties(config_properties)
                except Exception as ex:
                    raise Exception('Cannot instanciate TemplateRenderer with configuration file "%s" because %s' % (config_file, ex))

    @property
    def properties(self) -> dict:
        """Return the current set (mutable) of properties associated with this TemplateRenderer instance"""
        return self.template_data

    def addProperty(self, key, value):
        key, value = shadoker_globals.nestValue(key, value)
        self._addProperty(self.template_data, key, value)

    def addProperties(self, props: dict):
        for k in props:
            self.addProperty(k, props[k])
            
    def _render(self, value):
        if (isinstance(value, dict)):
            transformed_dict_value = dict()
            for k in value:
                kk, vv = shadoker_globals.nestValue(k, value[k])
                self._addProperty(transformed_dict_value, kk, vv)
            return transformed_dict_value
        elif (isinstance(value, list)):
            return [self._render(v) for v in value]
        elif (isinstance(value, str)):
            return pystache.render(value, self.template_data)
        else:
            return value

    def _addProperty(self, dic, key, value):
        shadoker_globals.deepupdate(dic, {key: self._render(value)})

    def renderJsonFile(self, file_name: str) -> dict:
        with open(file_name) as f:
            text = f.read()
            data = self.renderJsonString(text)
            return data

    def renderFile(self, input_file_name: str, output_file_name: str) -> bool:
        with open(input_file_name) as f:
            text = f.read()
            rendered_text = self.renderString(text)
        with open(output_file_name, 'w') as f:
            f.write(rendered_text)

    def renderFileLoose(self, input_file_name: str, output_file_name: str) -> bool:
        with open(input_file_name) as f:
            text = f.read()
            rendered_text = self.renderString(text, False)
        with open(output_file_name, 'w') as f:
            f.write(rendered_text)

    def renderJsonString(self, s: str) -> dict:
        data = orjson.loads(self.renderString(s))
        return data

    def renderStrings(self, strings: List[str], strict: bool = False) -> List[str]:
        renderer = pystache.Renderer()
        renderer.missing_tags = 'strict'
        r = []
        for s in strings:
            try:
                r.append(renderer.render(s, self.template_data))
            except pystache.context.KeyNotFoundError as knfe:
                if (strict):
                    raise NameError(f'Missing template property {knfe}')
        return r

    def renderString(self, s: str, strict: bool = True) -> str:
        renderer = pystache.Renderer()
        if (strict):
            renderer.missing_tags = 'strict'
        try:
            return renderer.render(s, self.template_data)
        except pystache.context.KeyNotFoundError as knfe:
            raise NameError(f'Missing template property {knfe}')
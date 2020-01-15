# -*- coding: utf-8
""" TO DO """

import os
import sys
import json
import shutil
import tempfile
import cherrypy

import anvio
import anvio.db as db
import anvio.utils as utils
import anvio.terminal as terminal

from anvio.errors import ConfigError

progress = terminal.Progress()
run = terminal.Run()
pp = terminal.pretty_print


AbsolutePath = lambda x: os.path.abspath(x)
Exist = lambda x: os.path.exists(x)
Join = lambda *x: os.path.join(x)
Dirname = lambda x: os.path.dirname(x)


class ElmApp():
    def __init__(self, project = None,
                       root = None,
                       main = 'src/Main.elm',
                       dist = 'dist/main.js',
                       debug = True if anvio.__version__.endswith('-master') else False,
                       ):
        utils.is_program_exists('elm')

        self.debug = debug
        self.main = main
        self.dist = dist

    def build(self):
        if (not Exists(Join(self.web_root, dist))) or self.debug:
            if self.debug:
                os.remove(self.dist)

            # TO DO: Building dist, maybe parse output in future?
            # and return error to the web interface? or create dump file and
            # show github link.
            os.system("elm make \
                       %s %s --output %s" % ('--optimize' if self.debug else '',
                                              self.main,
                                              self.dist))

    @cherrypy.expose
    def index(self):
        return "Hello World"


    def load_project_flags(self, project_spec_file):
        default = {
            "name": "Unnamed Project",
            "version": anvio.__version__,
            "data": {}
        }

        # TO DO: actually loads/process project.json
        self.flags = default


class HomepageApplication():
    def __init__(self):
        pass

    @cherrypy.expose
    def index(self):
        return "anvi'o interactive homepage placeholder"


class HttpServer():
    def __init__(self, ip_address = None
                     , port = None):
        cherrypy.tree.mount(HomepageApplication(), '/')
        cherrypy.config.update({'server.socket_host': ip_address or '0.0.0.0',
                                'server.socket_port': port or 8080,
                               })

    def run_application(self, application, mount = '/'):
        cherrypy.tree.mount(application, mount)

    def start(self):
        cherrypy.engine.start()
        cherrypy.engine.block()

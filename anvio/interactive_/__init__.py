# -*- coding: utf-8
""" TO DO """

import os
import sys
import json
import shutil
import tempfile
import cherrypy
import subprocess

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
Join = lambda *x: os.path.join(*x)
Dirname = lambda x: os.path.dirname(x)


class ElmApp():
    def __init__(self, project = None, app_root = None, main = None, dist = None):
        utils.is_program_exists('elm')

        if not app_root:
            raise Exception("Please specify what application to run. ")

        self.debug = True if anvio.__version__.endswith('-master') else False
        self.main = main or 'src/Main.elm'
        self.dist = dist or ('static/js/%sApp.js' % (os.path.basename(app_root)))

        self.web_root = Join(tempfile.mkdtemp(), 'app')
        shutil.copytree(app_root, self.web_root)


    def build(self):
        if ((not Exist(self.dist)) or self.debug):
            try:
                os.remove(self.dist)
            except:
                pass


        try:
            output = subprocess.check_output(['elm',
                                              'make',
                                              self.main,
                                              '--output',
                                              self.dist])
            return output
        except Exception as e:
            return str(e)



    @cherrypy.expose
    def index(self):
        os.chdir(self.web_root)
        try:
            self.build()
        except Exception as e:
            return str(e)

        content = None
        with open('index.html', 'r') as f:
            content = f.read()
            content = content.replace('{{dist}}', self.dist)

        return content


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

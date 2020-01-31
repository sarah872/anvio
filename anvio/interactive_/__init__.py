# -*- coding: utf-8
""" TO DO """

import os
import sys
import json
import shutil
import tempfile
import cherrypy
import subprocess
from datetime import datetime
from cherrypy.lib.static import serve_file

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
    def __init__(self, project_file = None, app_root = None, main = None):
        utils.is_program_exists('elm')

        if not app_root:
            raise Exception("Please specify what application to run. ")

        self.debug = True if anvio.__version__.endswith('-master') else False
        self.main = main or 'src/Main.elm'

        self.web_root = app_root

        if not self.debug:
            self.web_root = Join(tempfile.mkdtemp(), 'app')
            shutil.copytree(app_root, self.web_root)

        run.info('Web root', self.web_root)

        self.project_file_path = project_file
        self.project_flags = self.load_project_flags(AbsolutePath(project_file))


    @cherrypy.expose
    def index(self):
        try:
            subprocess.check_output(['elm',
                                     'make', self.main,
                                     '--output', Join(self.web_root, 'dist.js'),
                                     '--report', 'json'],
                                    cwd = self.web_root,
                                    stderr = subprocess.STDOUT,
                                    universal_newlines = True)

            now = datetime.now()
            run.info_single("%s (%s)." % ("Built successfull",
                                            now.strftime("%d/%m/%Y %H:%M:%S")))

        except subprocess.CalledProcessError as exc:
            body = "<html><head>" \
                   "<script src='/static/js/errors.js'></script>" \
                   "</head>" \
                   "<body><script>" \
                   "Elm.Errors.init({flags: " + exc.output + "});" \
                   "</script></body></html>"
            return body

        with open(Join(self.web_root, 'dist.js'), 'r') as js:
            with open(Join(self.web_root, 'index.html'), 'r') as f:
                return f.read().replace('{{dist}}', js.read())


    @cherrypy.expose
    def meta(self):
        return json.dumps(self.project_flags)


    @cherrypy.expose
    def data(self, dataId = None):
        if not dataId in self.project_flags['data']:
            raise cherrypy.HTTPError(status=404, message="Data not found.")

        return serve_file(AbsolutePath(
                            Join(
                                Dirname(self.project_file_path),
                                self.project_flags['data'][dataId]
                                )
                          ),
                          "application/x-download",
                          "attachment")


    def load_project_flags(self, project_spec_file):
        default = {
            "name": "Unnamed Project",
            "version": anvio.__version__,
            "data": {}
        }

        flags = {}
        try:
            with open(project_spec_file, 'r') as f:
                flags = json.loads(f.read())

                if self.debug:
                    print("Found and loading %s" % project_spec_file)
                    print(json.dumps(flags, indent=4))

                for key, value in flags.items():
                    default[key] = value
        except:
            run.warning("'%s' is not a valid anvi'o project specification file. \
                        Using default, please use '--debug' to see full flags." %
                        project_spec_file)

            if self.debug:
                print(json.dumps(default, indent=4))

        return default


class HomepageApplication():
    def __init__(self):
        pass

    @cherrypy.expose
    def index(self):
        return "anvi'o interactive homepage placeholder"


class HttpServer():
    def __init__(self, ip_address = None
                     , port = None):
        cherrypy.config.update({'server.socket_host': ip_address or '0.0.0.0',
                                'server.socket_port': port or 8080})

        cherrypy.tree.mount(HomepageApplication(), '/', config = {
          '/static' : {
            'tools.staticdir.on' : True,
            'tools.staticdir.dir' : Join(Dirname(__file__), 'static'),
            'tools.staticdir.content_types' : {'html': 'application/octet-stream'}
          }
        })

    def run_application(self, application, mount = '/'):
        cherrypy.tree.mount(application, mount, config = {
          '/static' : {
            'tools.staticdir.on' : True,
            'tools.staticdir.dir' : os.path.join(application.web_root, 'static'),
            'tools.staticdir.content_types' : {'html': 'application/octet-stream'}
          }
        })

    def start(self):
        cherrypy.engine.start()
        cherrypy.engine.block()
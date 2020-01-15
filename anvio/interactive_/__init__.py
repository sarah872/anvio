# -*- coding: utf-8
""" TO DO """

import os
import sys
import json
import flask
import shutil
import tempfile

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
                       app = None,
                       main = 'src/Main.elm',
                       dist = 'dist/main.js',
                       debug = True if anvio.__version__.endswith('-master') else False,
                       ):
        utils.is_program_exists('elm')

        self.debug = debug
        self.web_root = app
        self.using_temp_web_root = False

        self.main = main
        self.dist = dist

        if not os.access(AbsolutePath(self.web_root), os.W_OK):
            self.web_root = Join(tempfile.mkdtemp(), 'app')
            shutil.copytree(app, self.web_root)
            self.using_temp_web_root = True


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

    def load_project_flags(self, project_spec_file):
        default = {
            "name": "Unnamed Project",
            "version": anvio.__version__,
            "data": {}
        }

        # TO DO: actually loads/process project.json
        self.flags = default


    def __del__(self):
        # Clean up the clutter.
        if self.using_temp_web_root:
            if self.debug:
                run.info('Keeping path for debug', self.web_root)
            else:
                shutil.rmtree(self.web_root)

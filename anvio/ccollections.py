# -*- coding: utf-8

"""Implements the collections class (the file name has an extra 'c' to avoid
masking the standard collections library).

If the user have analyzed their metagenome using a metagenome binning software
and identified draft genomes in their data (or by any other means binned their
contigs based on any criterion), this information can be stored in the
annotation database's collections_* tables. The class implemented here collects
this information from the database, and presents it as an intuitive data structure
for the client.
"""


import anvio
import anvio.db as db
import anvio.tables as t
import anvio.utils as utils
import anvio.terminal as terminal
import anvio.filesnpaths as filesnpaths

from anvio.errors import ConfigError


__author__ = "A. Murat Eren"
__copyright__ = "Copyright 2015, The anvio Project"
__credits__ = []
__license__ = "GPL 3.0"
__version__ = anvio.__version__
__maintainer__ = "A. Murat Eren"
__email__ = "a.murat.eren@gmail.com"
__status__ = "Development"


run = terminal.Run()
progress = terminal.Progress()


class Collections:
    def __init__(self, r = run, p = progress):
        self.sources_dict = {}
        self.run = r
        self.progress = p


    def populate_sources_dict(self, db_path, version):
        database = db.DB(db_path, version)
        db_type = database.get_meta_value('db_type')
        collections_info_table = database.get_table_as_dict(t.collections_info_table_name)
        database.disconnect()

        # collections info must be read only if its coming from the annotation database.
        if db_type == 'annotation':
            read_only = True
        elif db_type == 'profile':
            read_only = False
        else:
            raise ConfigError, 'Collections class does not know about this "%s" database type :/' % db_type

        for source in collections_info_table:
            self.sources_dict[source] = collections_info_table[source]
            self.sources_dict[source]['read_only'] = read_only
            self.sources_dict[source]['source_db_path'] = db_path
            self.sources_dict[source]['source_db_version'] = version


    def sanity_check(self, source):
        if source not in self.sources_dict:
            raise ConfigError, 'There is no "%s" I know of. Maybe the populate_sources_dict was not called\
                                for whatever database you are trying to get collections from? (anvio asks this\
                                rhetorical question to the programmer).'


    def get_collection_dict(self, source):
        self.sanity_check(source)

        c = self.sources_dict[source]

        database = db.DB(c['source_db_path'], c['source_db_version'])
        collections_splits_table = database.get_table_as_dict(t.collections_splits_table_name)
        database.disconnect()

        # FIXME: this could be resolved with a WHERE clause in the SQL query:
        collection = utils.get_filtered_dict(collections_splits_table, 'source', set([source]))

        collection_dict = {}

        for entry in collection.values():
            source = entry['source']
            cluster_id = entry['cluster_id']
            split = entry['split']

            if collection_dict.has_key(cluster_id):
                collection_dict[cluster_id].append(split)
            else:
                collection_dict[cluster_id] = [split]

        return collection_dict


    def get_collection_colors(self, source):
        self.sanity_check(source)

        c = self.sources_dict[source]

        database = db.DB(c['source_db_path'], c['source_db_version'])
        collections_colors = database.get_table_as_dict(t.collections_colors_table_name)
        database.disconnect()

        # FIXME: this could be resolved with a WHERE clause in the SQL query:
        collection = utils.get_filtered_dict(collections_colors, 'source', set([source]))

        collection_color_dict = {}

        for entry in collection.values():
            collection_color_dict[entry['cluster_id']] = entry['htmlcolor']

        return collection_color_dict


    def list_collections(self):
        for collection_id in self.sources_dict:
            c = self.sources_dict[collection_id]
            output = '%s (%d clusters, representing %d splits).' % (collection_id, c['num_clusters'], c['num_splits'])
            self.run.info_single(output)


class GetSplitNamesInBins:
    """Returns a tuple: (bins, split_names)"""
    def __init__(self, args):
        # we will fill this in and return it
        self.split_names_of_interest = set([])

        A = lambda x: args.__dict__[x] if args.__dict__.has_key(x) else None
        self.bin_ids_file_path = A('bin_ids_file')
        self.bin_id = A('bin_id')
        self.collection_id = A('collection_id')
        self.annotation_db_path = A('annotation_db')
        self.profile_db_path = A('profile_db')
        self.debug = A('debug')


    def get(self):
        if self.bin_ids_file_path and self.bin_id:
            raise ConfigError, 'Either use a file to list all the bin ids (-B), or declare a single bin (-b)\
                                you would like to focus. Not both :/'
        if (not self.bin_ids_file_path) and (not self.bin_id):
            raise ConfigError, 'You must either use a file to list all the bin ids (-B) you would like to\
                                further analyze, or declare a single bin id (-b). You have not really given\
                                us anything to work with.'

        if self.bin_ids_file_path:
            filesnpaths.is_file_exists(self.bin_ids_file_path)
            self.bins = set([b.strip() for b in open(self.bin_ids_file_path).readlines()])
        if self.bin_id:
            self.bins = set([self.bin_id])

        if not len(self.bins):
            raise ConfigError, 'There is no bin to work with :/'

        self.collections = Collections()
        self.collections.populate_sources_dict(self.profile_db_path, anvio.__profile__version__)

        if self.collection_id not in self.collections.sources_dict:
            raise ConfigError, 'The collection id "%s" does not seem to be in the profile database. These are the\
                                collections that are available through this profile database: %s.'\
                                                    % (self.collection_id, ', '.join(self.collections.sources_dict))

        collection_dict = self.collections.get_collection_dict(self.collection_id)

        bins_in_collection = collection_dict.keys()

        bins_that_does_not_exist_in_collection = [b for b in self.bins if b not in bins_in_collection]
        if len(bins_that_does_not_exist_in_collection):
            raise ConfigError, 'Some of the bins you requested does not appear to have been described in the collection\
                                "%s". Here is a list of bins that are missing: %s'\
                                        % (self.collection_id, ', '.join(bins_that_does_not_exist_in_collection))

        split_names_of_interest = []
        for bin_id in self.bins:
            split_names_of_interest.extend(collection_dict[bin_id])

        self.split_names_of_interest = set(split_names_of_interest)

        if not len(self.split_names_of_interest):
            raise ConfigError, 'Something went wrong :/ There are no split names associated in the profile database for\
                                the combination of collection id and bin ids you requested. This should have never\
                                happened...'

        return (self.bins, self.split_names_of_interest)



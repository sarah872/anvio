# -*- coding: utf-8
# pylint: disable=line-too-long
""" TO DO """

import os
import sys
import json

import anvio
import anvio.db as db
import anvio.terminal as terminal

progress = terminal.Progress()
run = terminal.Run()
pp = terminal.pretty_print


class GenomeViewer():
    def __init__(self, args, run=run, progress=progress):
        self.run = run
        self.progress = progress
        self.args = args
        self.mode = 'genome'

        A = lambda x: args.__dict__[x] if x in args.__dict__ else None
        self.pan_db_path = A('pan_db')
        self.genomes_storage_path = A('genomes_storage')
        self.gene_callers_id = A('gene_callers_id')

        self.genome_name = 'E_faecalis_6240'
        self.gene_callers_id = 1338

    def get_neighbors(self):
        pan_db = db.DB(self.pan_db_path, anvio.__pan__version__)
        genome_storage = db.DB(self.genomes_storage_path, anvio.__genomes_storage_version__)
        

        gene_cluster_row = pan_db.get_some_rows_from_table_as_dict(
            'gene_clusters', 'genome_name LIKE "%s" and gene_caller_id LIKE "%s"' % (self.genome_name, str(self.gene_callers_id)))

        gene_cluster_id = next(iter(gene_cluster_row.values()))['gene_cluster_id']

        genes_in_cluster = pan_db.get_some_rows_from_table_as_dict(
            'gene_clusters', 'gene_cluster_id LIKE "%s"' % (gene_cluster_id))

        results = []

        for entry_id in genes_in_cluster:
            gene_callers_id = genes_in_cluster[entry_id]['gene_caller_id']
            genome_name = genes_in_cluster[entry_id]['genome_name']

            target_gene = genome_storage.get_some_rows_from_table_as_dict(
                'genes_in_contigs', 'genome_name LIKE "%s" and gene_callers_id LIKE "%s"' % (genome_name, str(gene_callers_id)))
            target_gene = target_gene[gene_callers_id]

            window = 10000
            neighbors = genome_storage.get_some_rows_from_table_as_dict(
                'genes_in_contigs', 'genome_name LIKE "%s" and \
                                     start >= %d and \
                                     stop <= %d' % (genome_name, 
                                                   target_gene['start'] - window,
                                                   target_gene['stop'] + window))

            results.extend(neighbors.values())


        return results









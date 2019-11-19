# -*- coding: utf-8
# pylint: disable=line-too-long
""" TO DO """

import os
import sys

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

        pan_db = db.DB(self.pan_db_path, anvio.__pan__version__)
        genome_storage = db.DB(self.genomes_storage_path, anvio.__genomes_storage_version__)

        self.gene_to_split = dict()
        self.split_to_genes = dict()
        self.gene_info = dict()

        self.gene_to_cluster = dict()
        self.clusters = dict()

        for row in pan_db.get_all_rows_from_table('gene_clusters'):
            entry_id, gene_caller_id, gene_cluster_id, genome_name, alignment_summary = row

            gene = (genome_name, gene_caller_id)

            self.gene_to_cluster[gene] = gene_cluster_id

            if gene_cluster_id not in self.clusters:
                self.clusters[gene_cluster_id] = set([])

            self.clusters[gene_cluster_id].add(gene)

        print(self.gene_info)










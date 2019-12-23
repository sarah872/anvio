import { GenomeViewer } from './genomeViewer.js';
import { Contig } from './contig.js';
import { Ribbon } from './ribbon.js';

$(window).on("load", () => { init(); });

function init() {
    var max = -1;
    const genomeViewer = new GenomeViewer({
        'canvas': document.getElementById('canvas'),
    });


    fetch('/data/get_neighbors').then((response) => {
        response.json().then((data) => {
            console.log(data);
            for (const genome_name in data.contigs) {
                let track = genomeViewer.getTrack(genome_name);

                for (const contig_name in data.contigs[genome_name]) {
                    let contig_info = data.contigs[genome_name][contig_name];

                    let contig = new Contig(genomeViewer);
                    contig.name = contig_name;
                    contig.length = contig_info.length;
                    track.contigs.push(contig);
                }
            }


            data.genes.forEach((gene) => {
                let genome_name = gene['genome_name'];

                let track = genomeViewer.getTrack(genome_name);
                track.contigs[0].genes.push({
                    'gene_callers_id': gene[
                        'gene_callers_id'],
                    'start': gene['start'],
                    'stop': gene['stop'],
                    'direction': gene['direction']
                });
            });
            let min = -1;

            for (const cluster_name in data.clusters) {
                genomeViewer.ribbons.push(new Ribbon(genomeViewer, data.clusters[
                    cluster_name]));

                let gene_start_pos = [];
                let contig_lengths = [];
                data.clusters[cluster_name].forEach((cluster) => {
                    const {
                        genome_name,
                        gene_callers_id
                    } = cluster;

                    let track = genomeViewer.getTrack(genome_name);
                    let gene = track.contigs[0].getGene(
                        gene_callers_id);
                    gene_start_pos.push(gene.start);
                });
                min = Math.min(...gene_start_pos);

                data.clusters[cluster_name].forEach((cluster) => {
                    const {
                        genome_name,
                        gene_callers_id
                    } = cluster;

                    let track = genomeViewer.getTrack(genome_name);
                    let contig = track.contigs[0];
                    let gene = contig.getGene(gene_callers_id);

                    contig.offsetX = min - gene.start;

                    contig_lengths.push(contig.offsetX + contig.length);
                });
                max = Math.max(...contig_lengths);
            }
            genomeViewer.centerPosBase = min;
            genomeViewer.handleResize();
            genomeViewer.center(min);
        });
    });
}

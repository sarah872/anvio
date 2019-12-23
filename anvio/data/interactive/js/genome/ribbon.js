
class Ribbon {
    constructor(viewer, geneList) {
        this.viewer = viewer;
        this.geneList = [];

        geneList.forEach((geneEntry) => {
            let track = this.viewer.getTrack(geneEntry.genome_name);
            let contig = track.contigs[0];
            let gene = contig.getGene(geneEntry.gene_callers_id);

            this.geneList.push({
                'contig': contig,
                'gene': gene
            });
        });
    }
 
    draw() {
        let ctx = this.viewer.context;
        let points = [];

        this.geneList.forEach((geneEntry) => {
            let gene = geneEntry.gene;
            let contig = geneEntry.contig;
            let start = this.viewer.centerPos + contig.offsetXpx + (contig.offsetX + (gene.direction ==
                'f' ?
                gene.start : gene.stop) - this.viewer.centerPosBase) * this.viewer.xscale;
            points.push({
                'x': start,
                'y': contig.offsetY
            });
            points.push({
                'x': start,
                'y': contig.offsetY + 16
            });
        });

        this.geneList.slice().reverse().forEach((geneEntry) => {
            let gene = geneEntry.gene;
            let contig = geneEntry.contig;
            let stop = this.viewer.centerPos + contig.offsetXpx + (contig.offsetX + (gene.direction ==
                'f' ?
                gene.stop : gene.start) - this.viewer.centerPosBase) * this.viewer.xscale;

            points.push({
                'x': stop,
                'y': contig.offsetY + 16
            });
            points.push({
                'x': stop,
                'y': contig.offsetY
            });
        });

        ctx.beginPath();
        ctx.fillStyle = "rgba(0, 200, 0, 0.2)";

        let first = points.pop();
        ctx.moveTo(first.x, first.y);
        while (points.length) {
            let point = points.pop();
            ctx.lineTo(point.x, point.y);
        }

        ctx.fill();
    }   
}

export { Ribbon };

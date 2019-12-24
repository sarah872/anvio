
class Contig {
    constructor(viewer) {
        this.viewer = viewer;
        this.name = null;
        this.length = 0;
        this.genes = [];
    }

    addGene(geneData) {
        this.genes.push(geneData);
    }

    getGene(gene_callers_id) {
        let gene = this.genes.find((gene) => {
            return (gene.gene_callers_id == gene_callers_id);
        });
        return gene;
    }

    scale(point) {
        return parseInt(point / this.viewer.basesPerPixel);
    }

    getBuffer() {
        let buffer = new OffscreenCanvas(this.scale(this.length), 20);
        let ctx = buffer.getContext('2d');

        // draw background
        ctx.beginPath();
        ctx.fillStyle = "rgba(0, 0, 0, 0.2)";
        ctx.rect(0, 3, this.scale(this.length), 10);
        ctx.fill();

        // draw genes
        this.genes.forEach((gene) => {
            let start = this.scale(gene.start);
            let width = this.scale(gene.stop - gene.start);

            let triangleWidth = (width >= 10) ? 10 : width;

            ctx.beginPath();
            ctx.fillStyle = "#F9A520";

            if (width > 4) {
                // draw arrow head
                if (gene.direction == 'f') {
                    ctx.moveTo(start + width - triangleWidth, 0);
                    ctx.lineTo(start + width, 8);
                    ctx.lineTo(start + width - triangleWidth, 16);
                } else {
                    ctx.moveTo(start + triangleWidth, 0);
                    ctx.lineTo(start, 8);
                    ctx.lineTo(start + triangleWidth, 16);
                }
            } else {
                // only rectangle
                ctx.rect(start, 3, width, 10);
            }

            // draw rectangle near arrow head if there is space
            if (width - triangleWidth > 0) {
                if (gene.direction == 'f') {
                    ctx.rect(start, 3, width - triangleWidth, 10);
                } else {
                    ctx.rect(start + triangleWidth, 3, width - triangleWidth, 10);
                }
            }
            ctx.fill();
        });

        return buffer;
    }
}

export { Contig };
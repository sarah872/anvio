
class Contig {
    constructor(viewer) {
        this.viewer = viewer;
        this.name = null;
        this.length = 0;
        this.offsetX = 0;
        this.offsetXpx = 0;
        this.genes = [];

        this.offsetY = 0;
    }

    getGene(gene_callers_id) {
        let gene = this.genes.find((gene) => {
            return (gene.gene_callers_id == gene_callers_id);
        });
        return gene;
    }

    draw() {
        let ctx = this.viewer.context;
        // draw background
        ctx.beginPath();
        ctx.fillStyle = "rgba(0, 0, 0, 0.2)";
        ctx.rect(this.viewer.centerPos + this.offsetXpx + (this.offsetX - this.viewer.centerPosBase) *
            this.viewer.xscale,
            this.offsetY + 3,
            this.length * this.viewer.xscale,
            10);
        ctx.fill();

        // draw genes
        this.genes.forEach((gene) => {
            let start = this.viewer.centerPos + this.offsetXpx + (this.offsetX + gene.start -
                    this.viewer.centerPosBase) *
                this.viewer.xscale;
            let width = (gene.stop - gene.start) * this.viewer.xscale;
            let triangleWidth = (width >= 10) ? 10 : width;

            // DEBUG
            ctx.fillRect(this.viewer.centerPos - 2, 0, 4, 20);
            // DEBUG

            ctx.beginPath();
            ctx.fillStyle = "#F9A520";

            if (width > 4) {
                // draw arrow head
                if (gene.direction == 'f') {
                    ctx.moveTo(start + width - triangleWidth, this.offsetY);
                    ctx.lineTo(start + width, this.offsetY + 8);
                    ctx.lineTo(start + width - triangleWidth, this.offsetY + 16);
                } else {
                    ctx.moveTo(start + triangleWidth, this.offsetY);
                    ctx.lineTo(start, this.offsetY + 8);
                    ctx.lineTo(start + triangleWidth, this.offsetY + 16);
                }
            } else {
                // only rectangle
                ctx.rect(start, this.offsetY + 3, width, 10);
            }

            // draw rectangle near arrow head if there is space
            if (width - triangleWidth > 0) {
                if (gene.direction == 'f') {
                    ctx.rect(start, this.offsetY + 3, width - triangleWidth, 10);
                } else {
                    ctx.rect(start + triangleWidth, this.offsetY + 3, width - triangleWidth,
                        10);
                }
            }
            ctx.fill();
        });
    }
}


export { Contig };
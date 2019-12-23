

class GenomeTrack {
    constructor(viewer) {
        this.viewer = viewer;
        this.contigs = [];
    }

    draw() {
        this.contigs.forEach((contig) => {
            contig.draw();
        });
    }
}


export { GenomeTrack };
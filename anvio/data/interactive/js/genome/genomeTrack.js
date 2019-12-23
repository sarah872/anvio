import { Contig } from './contig.js';

class GenomeTrack {
    constructor(viewer) {
        this.viewer = viewer;
        this.contigs = [];
    }

    getContig(contigName) {
        let contig = this.contigs.find(contig => contig.name == contigName);
        console.log(arguments, contig);
        return contig;
    }

    addContig(contigData) {
        let contig = new Contig(this.viewer);
        
        contig.name = contigData.name;
        contig.length = contigData.length;

        this.contigs.push(contig);
    }

    draw() {
        this.contigs.forEach((contig) => {
            contig.draw();
        });
    }
}


export { GenomeTrack };
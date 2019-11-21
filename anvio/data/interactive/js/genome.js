
function Gene(props) {
    this.viewer = props.viewer;
    this.start = props.start;
    this.stop = props.stop;
}

Gene.prototype.draw = function(context, x, y, ) {
    let ctx = this.viewer.context;
    let start = this.start;
    let stop = this.stop;

    ctx.beginPath();
    ctx.rect(start, 10, stop - start, 10);
    ctx.stroke();
}

function GenomeViewer(options) {
    let defaults = {
        'canvas': '',
    }
    this.options = $.extend(defaults, options);
    this.canvas = this.options.canvas;
    this.context = this.canvas.getContext('2d');
    this.width = 0;
    this.height = 0;

    this.tracks = [new GenomeTrack(this), 
                   new GenomeTrack(this),
                   new GenomeTrack(this)];

    this.canvas.addEventListener('mousemove', (event) => this.handleMouseMove(event));
    this.canvas.addEventListener('mousedown', (event) => this.handleMouseDown(event));
    this.canvas.addEventListener('mouseup', (event) => this.handleMouseUp(event));
    window.addEventListener('resize', (event) => this.handleResize(event));

    this.mouseDown = false;
    this.offset = {'x': 0, 'y': 0};
    this.pan_start = {'x': 0, 'y': 0};
    this.xscale = 0.1;
}

GenomeViewer.prototype.handleMouseMove = function(event) {
    if (this.mouseDown) {
        this.offset = {'x': event.x - this.pan_start.x, 'y': event.y - this.pan_start.y};
        this.draw();
    }
}

GenomeViewer.prototype.handleMouseDown = function(event) {
    this.pan_start = {'x': this.offset.x + event.x, 'y': this.offset.y + event.y};
    this.mouseDown = true;
}

GenomeViewer.prototype.handleMouseUp = function(event) {
    this.mouseDown = false;
}


GenomeViewer.prototype.handleResize = function(event) {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
    this.width = this.canvas.width;
    this.height = this.canvas.height;
    this.draw();
}

GenomeViewer.prototype.center = function(event) {
    let range = this.tracks[2].getRange();

    this.offset = {'x': -1 * range.min, 'y': 100}
    this.xscale = this.width / (range.max - range.min);
    this.draw();
}

GenomeViewer.prototype.draw = function() {
    this.context.clearRect(0, 0, this.width, this.height);
    this.tracks.forEach((track, order) => { 
        track.draw(this.context, order * 20); 
    });
}

function GenomeTrack(viewer) {
    this.viewer = viewer;
    this.contigs = [new Contig(this.viewer)];
}

GenomeTrack.prototype.getRange = function() {
    let min = -1;
    let max = -1;
    this.contigs.forEach((contig) => {
        let contigRange = contig.getRange();
        if (min == -1) {
            min = contigRange.min;
        }
        else {
            min = Math.min(min, contigRange.min);
        }
        if (max == -1) {
            max = contigRange.max;
        }
        else {
            max = Math.max(max, contigRange.max);
        }
    });

    return {'min': min, 'max': max};
}

GenomeTrack.prototype.draw = function(context, offset) {
    this.contigs.forEach((contig) => { 
        contig.draw(context, offset); 
    });
}

function Contig(viewer) {
    this.viewer = viewer;
    this.genes = [];
}

Contig.prototype.getRange = function() {
    let min = -1;
    let max = -1;
    this.genes.forEach((gene) => {
        if (min == -1) {
            min = gene.start;
        }
        else {
            min = Math.min(min, gene.start);
        }
        if (max == -1) {
            max = gene.stop;
        }
        else {
            max = Math.max(max, gene.stop);
        }
    });

    return {'min': min, 'max': max};
}

Contig.prototype.draw = function() {
    this.genes.forEach((gene) => { 
        gene.draw(); 
    });
}
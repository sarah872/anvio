
function Gene(props) {
    this.viewer = props.viewer;
    this.start = props.start;
    this.end = props.end;
}

Gene.prototype.draw = function() {
    let ctx = this.viewer.context;
    ctx.beginPath();
    ctx.rect(this.viewer.offset.x + this.start, this.viewer.offset.y, this.end - this.start, 10);
    ctx.stroke();
}

function GenomeViewer(options) {
    let defaults = {
        'canvas': '',
        'vidth': 800,
        'height': 600
    }
    this.options = $.extend(defaults, options);
    this.canvas = this.options.canvas;
    this.context = this.canvas.getContext('2d');

    this.tracks = [new GenomeTrack(this)];

    this.canvas.addEventListener('mousemove', (event) => this.handleMouseMove(event));
    this.canvas.addEventListener('mousedown', (event) => this.handleMouseDown(event));
    this.canvas.addEventListener('mouseup', (event) => this.handleMouseUp(event));

    this.dragging = false;
    this.offset = {'x': 0, 'y': 0};
}

GenomeViewer.prototype.handleMouseMove = function(event) {
    if (this.dragging) {
        this.offset = {'x': event.x - this.pan_start.x, 'y': event.y - this.pan_start.y};
        this.draw();
    }
}

GenomeViewer.prototype.handleMouseDown = function(event) {
    this.pan_start = {'x': event.x, 'y': event.y};
    this.dragging = true;
}

GenomeViewer.prototype.handleMouseUp = function(event) {
    this.dragging = false;
    this.offset = {'x': event.x - this.pan_start.x, 'y': event.y - this.pan_start.y};
    this.draw();
}

GenomeViewer.prototype.draw = function() {
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.tracks.forEach((track) => { track.draw(this.context); });
}

function GenomeTrack(viewer) {
    this.viewer = viewer;
    this.contigs = [new Contig(this.viewer)];
}

GenomeTrack.prototype.draw = function() {
    this.contigs.forEach((contig) => { contig.draw(); });
}

function Contig(viewer) {
    this.viewer = viewer;
    this.genes = [];
    this.genes.push(new Gene({
        'viewer': this.viewer,
        'gene_callers_id': '101', 
        'start': 50,
        'end': 100}));
    this.genes.push(new Gene({
        'viewer': this.viewer,
        'gene_callers_id': '101', 
        'start': 150,
        'end': 200}));

}

Contig.prototype.draw = function() {
    this.genes.forEach((gene) => { gene.draw(); });
}

function Gene(props) {
    this.viewer = props.viewer;
    this.start = props.start;
    this.stop = props.stop;
    this.direction = props.direction;
}

Gene.prototype.draw = function(context, offsetY) {
    let ctx = this.viewer.context;
    let start = this.start * this.viewer.xscale;
    let stop = this.stop * this.viewer.xscale;
    let width = stop - start;

    let triangleWidth = (width >= 10) ? 10 : width;

    ctx.beginPath();
    ctx.fillStyle = "#F9A520";

    if (this.direction == 'f') {
        ctx.moveTo(start + width - triangleWidth, offsetY);
        ctx.lineTo(start + width, offsetY + 8);
        ctx.lineTo(start + width - triangleWidth, offsetY + 16);
    }
    else
    {
        ctx.moveTo(start + triangleWidth, offsetY);
        ctx.lineTo(start, offsetY + 8);
        ctx.lineTo(start + triangleWidth, offsetY + 16);   
    }
    
    if (width - triangleWidth > 0) {
        if (this.direction == 'f')
        {
            ctx.rect(start, offsetY + 3, width - triangleWidth, 10);
        }
        else 
        {
            ctx.rect(start + triangleWidth, offsetY + 3, width - triangleWidth, 10);
        }
    }
    ctx.fill();
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

    this.trackNames = {};
    this.tracks = [];

    this.canvas.addEventListener('mousemove', (event) => this.handleMouseMove(event));
    this.canvas.addEventListener('mousedown', (event) => this.handleMouseDown(event));
    this.canvas.addEventListener('mouseup', (event) => this.handleMouseUp(event));
    this.canvas.addEventListener('wheel', (event) => this.handleWheel(event));
    window.addEventListener('resize', (event) => this.handleResize(event));

    this.mouseDown = false;
    this.backupTransformationMatrix = {};
    this.panStart = {'x': 0, 'y': 0};
    this.xscale = 1;
}

GenomeViewer.prototype.getTrack = function(name) {
    let index = -1;
    if (this.trackNames.hasOwnProperty(name)) {
        index = this.trackNames[name];
        return this.tracks[index];
    } else {
        index = this.tracks.length;
        this.tracks.push(new GenomeTrack(this));
        this.trackNames[name] = index;
    }
    return this.tracks[index];
}

GenomeViewer.prototype.handleMouseMove = function(event) {
    if (this.mouseDown) {
        let matrix = this.context.getTransform();
        this.context.setTransform(1, 
                                  0, 
                                  0, 
                                  1, 
                                  this.backupTransformationMatrix.e + event.x - this.panStart.x, 
                                  0);
        this.draw();
    }
}

GenomeViewer.prototype.handleMouseDown = function(event) {
    let matrix = this.context.getTransform();
    this.backupTransformationMatrix = matrix;
    this.panStart = {'x': event.x, 'y': 0 };
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

GenomeViewer.prototype.handleWheel = function(event) {
    let matrix = this.context.getTransform();
    if (event.deltaY < 0) {
        this.xscale = this.xscale * 0.98;
    } else {
        this.xscale = this.xscale * 1.02;
    }
    this.draw();
}


GenomeViewer.prototype.center = function(event) {
    let range = this.getRange();

    this.xscale = this.width / Math.abs(range.max - range.min);

    this.context.setTransform(1,0,0,1,
                              -1 * range.min * this.xscale,
                              0);
    this.draw();
}

GenomeViewer.prototype.getRange = function() {
    return {'min': Math.min.apply(Math, this.tracks.map(function(o) { return o.getRange()['min']; })),
            'max': Math.max.apply(Math, this.tracks.map(function(o) { return o.getRange()['max']; }))}
}


GenomeViewer.prototype.clear = function() {
    let ctx = this.context;
    // I have lots of transforms right now
    ctx.save();
    ctx.setTransform(1,0,0,1,0,0);
    // Will always clear the right space
    ctx.clearRect(0,0, this.width,this.height);
    ctx.restore();
    // Still have my old transforms
}

GenomeViewer.prototype.draw = function() {
    this.clear();

    this.tracks.forEach((track, order) => { 
        track.draw(this.context, 20 + order * 20); 
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

Contig.prototype.draw = function(context, offset) {
    this.genes.forEach((gene) => { 
        gene.draw(context, offset); 
    });
}
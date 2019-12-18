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
    this.ribbons = [];

    this.canvas.addEventListener('mousemove', (event) => this.handleMouseMove(event));
    this.canvas.addEventListener('mousedown', (event) => this.handleMouseDown(event));
    this.canvas.addEventListener('mouseup', (event) => this.handleMouseUp(event));
    this.canvas.addEventListener('wheel', (event) => this.handleWheel(event));
    window.addEventListener('resize', (event) => this.handleResize(event));

    this.mouseDown = false;
    this.panStart = {'x': 0, 'y': 0};

    this.windowSize = 10000;
    this.centerPos = 0;
    this.centerPosBase = 0;
    this.xscale = 0.1;
    this.lastScrollTime = 0;
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
        if (this.panStart.target) {
            this.panStart.target.contigs[0].offsetXpx = event.x - this.panStart.x;
        } else {
            this.centerPos = event.x - this.panStart.x;
        }
        this.draw();
    }
}

GenomeViewer.prototype.handleMouseDown = function(event) {
    this.mouseDown = true;

    let found = false;

    for (let i=0; i < this.tracks.length; i++) {
        if (event.y > this.tracks[i].contigs[0].offsetY + 3 && 
            event.y < this.tracks[i].contigs[0].offsetY + 13) {

            this.panStart = {'x': event.x - this.tracks[i].contigs[0].offsetXpx, 'y': event.y, 'target': this.tracks[i] };
            found = true;
        }
    }

    if (!found) {
        this.panStart = {'x': event.x - this.centerPos, 'y': event.y, 'target': null };
    }
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
    let deltaTime = Date.now() - this.lastScrollTime;
    if (deltaTime > 800) {
        let scale = event.deltaY * -0.01;
        this.xscale = Math.max(0.001, this.xscale + scale);
        this.draw();
        this.lastScrollTime = Date.now();
    }
}


GenomeViewer.prototype.center = function(target) {
    this.centerPos = this.width / 2;
    this.draw();
}

GenomeViewer.prototype.clear = function() {
    let ctx = this.context;

    ctx.save();
    ctx.setTransform(1,0,0,1,0,0);
    ctx.clearRect(0,0, this.width, this.height);
    ctx.restore();
}

GenomeViewer.prototype.draw = function() {
    this.clear();

    this.tracks.forEach((track, order) => {
        track.contigs[0].offsetY = 50 + order * 22;
    });
    this.ribbons.forEach((ribbon) => {
        ribbon.draw();
    });

    this.tracks.forEach((track, order) => {
        track.draw();
    });
}   

function GenomeTrack(viewer) {
    this.viewer = viewer;
    this.contigs = [];
}


GenomeTrack.prototype.draw = function() {
    this.contigs.forEach((contig) => { 
        contig.draw(); 
    });
}

function Contig(viewer) {
    this.viewer = viewer;
    this.name = null;
    this.length = 0;
    this.offsetX = 0;
    this.offsetXpx = 0;
    this.genes = [];

    this.offsetY = 0;
}

Contig.prototype.getGene = function(gene_callers_id) {
    let gene = this.genes.find((gene) => {
        return (gene.gene_callers_id == gene_callers_id);
    });
    return gene;
}


Contig.prototype.draw = function() {
    let ctx = this.viewer.context;
    // draw background
    ctx.beginPath();
    ctx.fillStyle = "rgba(0, 0, 0, 0.2)";
    ctx.rect(this.viewer.centerPos + this.offsetXpx + (this.offsetX - this.viewer.centerPosBase) * this.viewer.xscale,
                    this.offsetY + 3, 
                    this.length * this.viewer.xscale, 
                    10);
    ctx.fill();

    // draw genes
    this.genes.forEach((gene) => { 
        let start = this.viewer.centerPos + this.offsetXpx + (this.offsetX + gene.start - this.viewer.centerPosBase) * this.viewer.xscale;
        let width = (gene.stop - gene.start) * this.viewer.xscale;
        let triangleWidth = (width >= 10) ? 10 : width;

        // DEBUG
        ctx.fillRect(this.viewer.centerPos - 2, 0, 4, 20);
        // DEBUG

        ctx.beginPath();
        ctx.fillStyle = "#F9A520"; 

        if (gene.direction == 'f') {
            ctx.moveTo(start + width - triangleWidth, this.offsetY);
            ctx.lineTo(start + width, this.offsetY + 8);
            ctx.lineTo(start + width - triangleWidth, this.offsetY + 16);
        }
        else
        {
            ctx.moveTo(start + triangleWidth, this.offsetY);
            ctx.lineTo(start, this.offsetY + 8);
            ctx.lineTo(start + triangleWidth, this.offsetY + 16);   
        }

        if (width - triangleWidth > 0) {
            if (gene.direction == 'f')
            {
                ctx.rect(start, this.offsetY + 3, width - triangleWidth, 10);
            }
            else 
            {
                ctx.rect(start + triangleWidth, this.offsetY + 3, width - triangleWidth, 10);
            }
        }
        ctx.fill();
    });
}

function Ribbon(viewer, geneList) {
    this.viewer = viewer;
    this.geneList = [];

    geneList.forEach((geneEntry) => {
        let track = genomeViewer.getTrack(geneEntry.genome_name);
        let contig = track.contigs[0];
        let gene = contig.getGene(geneEntry.gene_callers_id);

        this.geneList.push({'contig': contig, 'gene': gene});
    });
}

Ribbon.prototype.draw = function() {
    let ctx = this.viewer.context;
    let points = [];

    this.geneList.forEach((geneEntry) => {
        let gene = geneEntry.gene; 
        let contig = geneEntry.contig;
        let start = this.viewer.centerPos + contig.offsetXpx + (contig.offsetX + (gene.direction == 'f' ? gene.start : gene.stop) - this.viewer.centerPosBase) * this.viewer.xscale;
        points.push({'x': start, 'y': contig.offsetY});
        points.push({'x': start, 'y': contig.offsetY + 16});
    });
/*
    let lastPoint = points[points.length - 1];
    points.push({'x': lastPoint.x, 'y': lastPoint.y + 16});

    let isFirst = true;
*/
    this.geneList.slice().reverse().forEach((geneEntry) => {
        let gene = geneEntry.gene; 
        let contig = geneEntry.contig;
        let stop = this.viewer.centerPos + contig.offsetXpx + (contig.offsetX + (gene.direction == 'f' ? gene.stop : gene.start) - this.viewer.centerPosBase) * this.viewer.xscale;
    /*
        if (isFirst) {
            points.push({'x': stop, 'y': contig.offsetY + 16});
            isFirst = false;    
        }*/
        points.push({'x': stop, 'y': contig.offsetY + 16});
        points.push({'x': stop, 'y': contig.offsetY});
    });

    ctx.beginPath();
    ctx.fillStyle = "rgba(0, 200, 0, 0.2)";

    let first = points.pop();
    ctx.moveTo(first.x, first.y);
    while(points.length) {
        let point = points.pop();
        ctx.lineTo(point.x, point.y);
    }

    ctx.fill();
}
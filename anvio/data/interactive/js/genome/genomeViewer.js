import { GenomeTrack } from './genomeTrack.js';

class GenomeViewer {
    constructor(options) {
        let defaults = {
            'canvas': '',
            'showGenomeLabels': true,
            'showGeneLabels': true,
            'showTree': true,
            'showGCContentOverlay': true,
        }

        this.options = $.extend(defaults, options);
        this.canvas = this.options.canvas;
        this.context = this.canvas.getContext('2d');
        this.width = 0;
        this.height = 0;

        this.genomeTrackNames = {};
        this.genomeTracks = [];

        this.ribbons = [];

        this.mouseDown = false;
        this.panStart = {
            'x': 0,
            'y': 0
        };

        this.windowSize = 10000;
        this.centerPos = 0;
        this.centerPosBase = 0;
        this.xscale = 0.1;
        this.lastScrollTime = 0;

        this.bindEvents();
    }

    /*
        Events:
    */

    bindEvents() {
        this.canvas.addEventListener('mousemove', (event) => this.handleMouseMove(event));
        this.canvas.addEventListener('mousedown', (event) => this.handleMouseDown(event));
        this.canvas.addEventListener('mouseup', (event) => this.handleMouseUp(event));
        this.canvas.addEventListener('wheel', (event) => this.handleWheel(event));
        window.addEventListener('resize', (event) => this.handleResize(event));
    }

    handleMouseMove(event) {
        if (this.mouseDown) {
            if (this.panStart.target) {
                this.panStart.target.contigs[0].offsetXpx = event.x - this.panStart.x;
            } else {
                this.centerPos = event.x - this.panStart.x;
            }
            this.draw();
        }
    }

    handleMouseDown(event) {
        this.mouseDown = true;
        this.panStart = {
            'x': event.x - this.centerPos,
            'y': event.y,
            'target': null
        };
    }

    handleMouseUp(event) {
        this.mouseDown = false;
    }

    handleResize(event) {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
        this.width = this.canvas.width;
        this.height = this.canvas.height;
        this.draw();
    }

    handleWheel(event) {
        let deltaTime = Date.now() - this.lastScrollTime;
        if (deltaTime > 800) {
            let scale = event.deltaY * -0.01;
            this.xscale = Math.max(0.005, this.xscale + scale);
            this.draw();
            this.lastScrollTime = Date.now();
        }
    }


    /*
        Drawing methods
    */

    center() {
        this.centerPos = this.width / 2;
        this.draw();
    }

    clear() {
        let ctx = this.context;

        ctx.save();
        ctx.setTransform(1,0,0,1,0,0);
        ctx.clearRect(0,0, this.width, this.height);
        ctx.restore();
    }

    draw() {
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

    /*
        Data access
    */
    
    getGenomeTrack(genomeName) {
        if (this.genomeTrackNames.hasOwnProperty(genomeName)) {
            return this.genomeTracks[this.genomeTrackNames[genomeName]];
        }

        let index = this.genomeTracks.length;
        let track = new GenomeTrack(this);

        this.genomeTracks.push(track);
        this.genomeTrackNames[genomeName] = index;

        return track;
    }


    addContig(genomeName, contigData) {
        let track = this.getGenomeTrack(genomeName);
        track.addContig(contigData);

    }

    addGene(genomeName, contigName, geneData) {
        let track = this.getGenomeTrack(genomeName);
        let contig = track.getContig(contigName);

        if (typeof contig === 'undefined') {
            console.log('Not found', arguments);
        }
        contig.addGene(geneData);
    }
}

export { GenomeViewer };


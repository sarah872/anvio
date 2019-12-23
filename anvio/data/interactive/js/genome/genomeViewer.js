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

        this.trackNames = {};
        this.tracks = [];
        this.ribbons = [];

        this.canvas.addEventListener('mousemove', (event) => this.handleMouseMove(event));
        this.canvas.addEventListener('mousedown', (event) => this.handleMouseDown(event));
        this.canvas.addEventListener('mouseup', (event) => this.handleMouseUp(event));
        this.canvas.addEventListener('wheel', (event) => this.handleWheel(event));
        window.addEventListener('resize', (event) => this.handleResize(event));

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

    }

    getTrack(name) {
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

        let found = false;

        for (let i = 0; i < this.tracks.length; i++) {
            if (event.y > this.tracks[i].contigs[0].offsetY + 3 &&
                event.y < this.tracks[i].contigs[0].offsetY + 13) {

                this.panStart = {
                    'x': event.x - this.tracks[i].contigs[0].offsetXpx,
                    'y': event.y,
                    'target': this.tracks[i]
                };
                found = true;
            }
        }

        if (!found) {
            this.panStart = {
                'x': event.x - this.centerPos,
                'y': event.y,
                'target': null
            };
        }
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
}

export { GenomeViewer };


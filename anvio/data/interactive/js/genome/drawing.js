class Layer {
    constructor(width, height) {
        this.width = width
        this.height = height

        this.objects = []
        ['rectangle', 'line', 'path'].forEach((currentType) => {
            this[currentType] = (params) => {
                this.objects.push({
                    type: currentType,
                    params: params
                })
            }
        })
    }


}

class RenderCanvas {
    constructor(layer, scaleX = 1, scaleY = 1) {
        this.layer = layer;
        this.xScale = (num) => num * scaleX;
        this.yScale = (num) => num * scaleY;
    }

    getBuffer() {
        let buffer = new OffscreenCanvas(this.layer.width, this.layer.height)
        let ctx = buffer.getContext('2d')



        for ({ type, params } of this.layer.objects) {
            ctx.beginPath()

            if (type == 'rectangle') {
                ctx.rect(params.x, 
                         params.y, this.scale(this.length), 10)
            } 

        ctx.fillStyle = "rgba(0, 0, 0, 0.2)";
                
        ctx.fill();
            }
        }
    }
}



export {
    Layer,
    RenderCanvas,
}
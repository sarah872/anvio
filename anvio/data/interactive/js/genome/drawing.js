class Layer {
    constructor(width, height) {
        this.width = width
        this.height = height

        this.objects = []
        this.knownShapes = ['rectangle', 'line', 'path']

        this.knownShapes.forEach((currentShape) => {
            // This creates member functions like Layer.rectangle()
            this[currentShape] = (params) => {
                this.objects.push({
                    shape: currentShape,
                    params: params
                })
            }
        })
    }
}


class RenderCanvas {
    constructor(layer, xScale = 1, yScale = 1) {
        this.layer = layer
        this.xScale = xScale
        this.yScale = yScale
    }

    scale(params, key) {
        let xScaleKeys = new Set(['x', 'width'])
        let yScaleKeys = new Set(['y', 'height'])

        if (!params.hasOwnAttribute(key)) {
            throw `Unknown parameter key ${key}.`
        }

        callOrScale = (thing, scale) => {
            if (thing instanceof Function) {
                return thing(scale)
            }
            return thing * scale;
        }

        if (xScaleKeys.has(key)) {
            return callOrScale(params.key, this.xScale)
        }

        if (yScaleKeys.has(key)) {
            return callOrScale(params.key, this.yScale)
        }

        return params.key
    }


    getBuffer() {
        params.has = key => params.hasOwnAttribute(key)
        params.get = key => this.scale(params, key)

        let buffer = new OffscreenCanvas(this.layer.width, this.layer.height)
        let ctx = buffer.getContext('2d')


        for ({ shape, params } of this.layer.objects) {
            ctx.beginPath()

            if (shape == 'rectangle') {
                ctx.rect(params.get('x'),
                         params.get('y'),
                         params.get('width'),
                         params.get('height'))
            }

            if (params.has('fillStyle'))
                ctx.fillStyle = params.fillStyle

            if (params.has('fill') && params.fill) {
                ctx.fill()
            } else {
                ctx.stroke()
            }
        }
    }
}



export {
    Layer,
    RenderCanvas,
}
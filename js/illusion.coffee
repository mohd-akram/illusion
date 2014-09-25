root = exports ? this

class Illusion
  constructor: (elem, @callback=null) ->
    @space = 1
    @speed = 7

    @gif = new SuperGif gif: elem, auto_play: false
    @gif.load @_loadCallback

  remove: -> @elem.parentNode.removeChild @elem

  play: ->
    return if @playing
    @playing = true
    @speed = 1 if @speed < 1
    @timer = setInterval =>
      x = parseInt(@maskCanvas.style.left)
      if x < @width * 2
        @maskCanvas.style.left = "#{x + @space}px"
      else @maskCanvas.style.left = '0px'
    , 500 / @speed

  pause: ->
    @playing = false
    clearInterval @timer

  _loadCallback: =>
    @lineWidth = @space * (@gif.get_length() - 1)

    canvas = @gif.get_canvas()
    canvas.width *= @space
    canvas.height *= @space

    @width = canvas.width
    @height = canvas.height

    ctx = canvas.getContext '2d'
    ctx.scale @space, @space
    ctx.imageSmoothingEnabled = false

    @_drawImage()
    @_drawMask()

    @elem = document.createElement 'div'

    @elem.appendChild el for el in [@maskCanvas, @imageCanvas]

    @elem.style.position = 'relative'
    @elem.style.top = '50%'
    @elem.style.marginTop = "#{-@height / 2}px"
    @elem.style.marginLeft = "#{-@width}px"

    @elem.ondragover = (e) -> e.preventDefault()

    @elem.ondrop = (e) =>
      e.preventDefault()
      file = e.dataTransfer.files[0]
      reader = new FileReader
      reader.readAsArrayBuffer(file)
      reader.onload = =>
        arr = new Uint8Array reader.result
        @remove()
        @gif.load_raw arr, @_loadCallback

    @callback @elem if @callback

  _drawImage: ->
    @imageCanvas = document.createElement 'canvas'
    @imageCanvas.width = @width
    @imageCanvas.height = @height
    @imageCanvas.style.zIndex = -1

    gifCtx = @gif.get_canvas().getContext '2d'

    ctx = @imageCanvas.getContext '2d'
    ctx.imageSmoothingEnabled = false

    for i in [0...@gif.get_length()]
      @gif.move_to i
      x = @lineWidth + i * @space
      while x < @imageCanvas.width
        imageData = gifCtx.getImageData x, 0, @space, @height
        ctx.putImageData imageData, x, 0
        x += @space + @lineWidth

  _drawMask: ->
    @maskCanvas = document.createElement 'canvas'
    @maskCanvas.width = @width
    @maskCanvas.height = @height

    ctx = @maskCanvas.getContext '2d'
    ctx.imageSmoothingEnabled = false

    imageData = ctx.createImageData @lineWidth, @maskCanvas.height
    for i in [0...imageData.data.length] by 4
      imageData.data[i + 0] = 0
      imageData.data[i + 1] = 0
      imageData.data[i + 2] = 0
      imageData.data[i + 3] = 255

    x = 0
    while x < @maskCanvas.width
      ctx.putImageData imageData, x, 0
      x += @lineWidth + @space

    new Draggabilly @maskCanvas

root.Illusion = Illusion

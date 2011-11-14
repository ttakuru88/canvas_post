$(document).ready ->
  canvas = $('#draw-area')
  ctx = canvas[0].getContext('2d')
  ctx.lineWidth = 1

  ctx.putPoint = (x, y)->
    @.beginPath()
    @.arc(x, y, @.lineWidth / 2.0, 0, Math.PI*2, false)
    @.fill()
    @.closePath()
  ctx.drawLine = (sx, sy, ex, ey)->
    @.beginPath()
    @.moveTo(sx, sy)
    @.lineTo(ex, ey)
    @.stroke()
    @.closePath()
  ctx.setColor = ->
    color = "rgb(#{red_slider.val()},#{green_slider.val()},#{blue_slider.val()})"
    @.strokeStyle = color
    @.fillStyle = color
    preview_color.css('background-color', color)
  ctx.savePrevData = ->
    @.prevImageData = @.getImageData(0, 0, canvas.width(), canvas.height())

  mousedown = false

  canvas.mousedown (e)->
    ctx.savePrevData()
    ctx.prevPos = getPointPosition(e)
    mousedown = true
    ctx.putPoint(ctx.prevPos.x, ctx.prevPos.y)

  canvas.mousemove (e)->
    return unless mousedown
    nowPos = getPointPosition(e)
    ctx.drawLine(ctx.prevPos.x, ctx.prevPos.y, nowPos.x, nowPos.y)
    ctx.putPoint(nowPos.x, nowPos.y)
    ctx.prevPos = nowPos

  canvas.mouseup (e)->
    mousedown = false
  canvas.mouseout (e)->
    mousedown = false

  getPointPosition = (e)->
    {x: e.pageX-canvas.offset().left-2, y: e.pageY-canvas.offset().top-2}

  $("#pen-width-slider").change ->
    ctx.lineWidth = $(@).val()
    $("#show-pen-width").text(ctx.lineWidth)

  red_slider = $("#pen-color-red-slider")
  green_slider = $("#pen-color-green-slider")
  blue_slider = $("#pen-color-blue-slider")
  preview_color = $("#preview-color")

  red_slider.change ->
    ctx.setColor()
    $("#show-pen-red").text($(@).val())
  green_slider.change ->
    ctx.setColor()
    $("#show-pen-green").text($(@).val())
  blue_slider.change ->
    ctx.setColor()
    $("#show-pen-blue").text($(@).val())

  $("#clear-button").click ->
    ctx.clearRect(0, 0, canvas.width(), canvas.height())

  $("#save-button").click ->
    url = canvas[0].toDataURL()
    $.post '/pictures', {data: url}, (data)->
      reloadPictures()

  $("#return-button").click ->
    ctx.putImageData(ctx.prevImageData, 0, 0)

  controll_buttons = $("#controll-panel .controll-button")
  controll_buttons.mouseenter ->
    $(@).addClass('button-over')
  controll_buttons.mouseout ->
    $(@).removeClass('button-over')

  reloadPictures = ->
    $.get '/pictures', (result)->
      ids = result.split(',')
      pictures = $("#pictures")
      pictures.empty()
      ids.forEach (id, i)->
        if parseInt(id) > 0
          pictures.append("<img src=\"/images/#{id}.png\" class=\"thumbnail\" />")
      thumb_pics = $("#pictures .thumbnail")
      thumb_pics.click ->
        image = new Image()
        image.src = $(@).attr('src')
        image.onload = ->
          ctx.clearRect(0, 0, canvas.width(), canvas.height())
          ctx.drawImage(image, 0, 0)
      thumb_pics.mouseenter ->
        $(@).addClass('thumbnail-over')
      thumb_pics.mouseout ->
        $(@).removeClass('thumbnail-over')

  reloadPictures()
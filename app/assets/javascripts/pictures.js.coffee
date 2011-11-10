$(document).ready ->
  canvas = $('#draw-area')
  pictures = $('#pictures .thumbnail')
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

  mousedown = false

  canvas.mousedown (e)->
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
    nowPos = getPointPosition(e)
    ctx.putPoint(nowPos.x, nowPos.y)
    mousedown = false

  getPointPosition = (e)->
    {x: e.pageX-canvas.offset().left-2, y: e.pageY-canvas.offset().top-2}

  $("#pen_width_slider").change ->
    ctx.lineWidth = $(@).val()
    $("#show_pen_width").text(ctx.lineWidth)

  red_slider = $("#pen_color_red_slider")
  green_slider = $("#pen_color_green_slider")
  blue_slider = $("#pen_color_blue_slider")
  preview_color = $("#preview_color")

  red_slider.change ->
    ctx.setColor()
    $("#show_pen_red").text($(@).val())
  $("#pen_color_green_slider").change ->
    ctx.setColor()
    $("#show_pen_green").text($(@).val())
  $("#pen_color_blue_slider").change ->
    ctx.setColor()
    $("#show_pen_blue").text($(@).val())

  $("#clear_button").click ->
    ctx.clearRect(0, 0, canvas.width(), canvas.height())

  $("#save_button").click ->
    url = canvas[0].toDataURL()
    $.post '/pictures', {data: url}, (data)->
      reloadPictures()

  reloadPictures = ->
    $.get '/pictures', (result)->
      ids = result.split(',')
      pictures = $("#pictures")
      pictures.empty()
      ids.forEach (id, i)->
        if parseInt(id) > 0
          pictures.append("<img src=\"/images/#{id}.png\" class=\"thumbnail\" />")

  reloadPictures()
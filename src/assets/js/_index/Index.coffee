window.glitch = window.glitch || {}

import Fluid from './Fluid'

export default class Index
  constructor: ->
    @initWebGL().then =>
      @animationId = null
      @startTime = new Date().getTime()
      @update()


  initWebGL: ->
    @container = document.querySelector '.js-mainCanvas'
    @renderer = new THREE.WebGLRenderer
      canvas: @container.querySelector 'canvas'
      alpha: true
      # antialias: true
    # @devicePixelRatio = Math.min(window.devicePixelRatio or 1, 2)
    @devicePixelRatio = 1
    @renderer.setPixelRatio @devicePixelRatio

    @scene = new THREE.Scene()

    @width = @container.offsetWidth
    @height = @container.offsetHeight

    @camera = new THREE.OrthographicCamera -@width * 0.5, @width * 0.5, @height * 0.5, -@height * 0.5, 0, 100
    @camera.position.z = 10

    if !@renderer.extensions.get('OES_texture_float')? and !@renderer.extensions.get('OES_texture_half_float')?
      alert 'not supported'

    # fluid
    @fluid = new Fluid @devicePixelRatio, @renderer, @camera

    # mouse
    @isMousePosInited = false
    @beforePointerPos = new THREE.Vector2()
    @pointerX = null
    @pointerY = null

    window.addEventListener 'resize', @resize
    window.addEventListener 'mousemove', @mouseMove
    window.addEventListener 'touchmove', @touchMove

    promise = @fluid.init('/assets/img/logo.png', @width, @height).then =>
      @scene.add @fluid.mesh
      @resize()

    @resize()
    return promise



  resize: (e = null)=>
    @width = @container.offsetWidth
    @height = @container.offsetHeight
    @renderer.setSize @width, @height
    @camera.top = @height * 0.5
    @camera.bottom = -@height * 0.5
    @camera.left = -@width * 0.5
    @camera.right = @width * 0.5
    @camera.updateProjectionMatrix()

    @fluid.resize @width, @height
    return


  updatePointerPos: (posX, posY)->

    return


  mouseMove: (e = null)=>
    @pointerX = e.clientX
    @pointerY = e.clientY
    return


  touchMove: (e = null)=>
    t = e.touches[0]
    @pointerX = t.clientX
    @pointerY = t.clientY
    return


  update: =>
    @animationId = requestAnimationFrame @update
    time = new Date().getTime() - @startTime

    pointerPos = new THREE.Vector2()
    if @pointerX?
      if !@isMousePosInited
        @isMousePosInited = true
        pointerPos = @beforePointerPos
      else
        pointerPos.set @pointerX, @pointerY

    @fluid.update time, pointerPos, @beforePointerPos
    @renderer.render @scene, @camera

    @beforePointerPos = pointerPos
    return

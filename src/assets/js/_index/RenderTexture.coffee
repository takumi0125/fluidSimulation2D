export default class RenderTexture
  constructor: (width, height, @renderer, @camera, @initShaderMaterial, @updateShaderMaterial)->
    @currentTextureIndex = 0

    @renderTargets = [ new THREE.WebGLRenderTarget(width, height, {
      magFilter: THREE.NearestFilter
      minFilter: THREE.NearestFilter
      wrapS: THREE.ClampToEdgeWrapping
      wrapT: THREE.ClampToEdgeWrapping
      format: THREE.RGBAFormat
      type: (if(/(iPad|iPhone|iPod)/g.test(navigator.userAgent)) then THREE.HalfFloatType else THREE.FloatType)
      depthBuffer: false
      stencilBuffer: false
      generateMipmaps: false
      shareDepthFrom: null
    })]
    @renderTargets[1] = @renderTargets[0].clone()

    planeGeometry = new THREE.PlaneGeometry(100, 100)

    @mesh = new THREE.Mesh planeGeometry, @initShaderMaterial

    @scene = new THREE.Scene()
    @scene.add @mesh

    @renderer.render @scene, @camera, @renderTargets[0]
    @renderer.render @scene, @camera, @renderTargets[1]

    @initShaderMaterial.dispose()
    @initShaderMaterial = null

    @mesh.material = @updateShaderMaterial

    @renderTargets[0].texture.flipY = false
    @renderTargets[1].texture.flipY = false


  setDefine: (name, value)->
    @updateShaderMaterial.defines[name] = value;
    return


  initUniforms: (uniforms)->
    for name, uniform of uniforms
      @updateShaderMaterial.uniforms[name] = uniform
    return


  updateUniform: (name, value)->
    @updateShaderMaterial.uniforms[name].value = value
    return


  update: ->
    @updateShaderMaterial.uniforms.texture.value = @getTexture()
    @swapTexture()
    @render()
    return


  render: ->
    @renderer.render @scene, @camera, @renderTargets[@currentTextureIndex]
    return


  setMeshMaterial: (material)->
    @mesh.material = material
    @mesh.material.needsUpdate = true
    return


  swapTexture: ->
    @currentTextureIndex = (@currentTextureIndex + 1) % 2
    return


  getTexture: ->
    return @getRenderTarget().texture


  getRenderTarget: ->
    return @renderTargets[@currentTextureIndex]


  resize: (width, height)->
    @renderTargets[0].setSize width, height
    @renderTargets[1].setSize width, height
    return

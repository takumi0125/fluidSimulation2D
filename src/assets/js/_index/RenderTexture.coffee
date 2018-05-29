export default class RenderTexture
  constructor: (width, height, @renderer, @camera, @initShaderMaterial, @updateShaderMaterial, type, commonGeometry = null)->
    @currentTextureIndex = 0

    @renderTargets = [ new THREE.WebGLRenderTarget(width, height, {
      magFilter: THREE.NearestFilter
      minFilter: THREE.NearestFilter
      wrapS: THREE.RepeatWrapping
      wrapT: THREE.RepeatWrapping
      format: THREE.RGBAFormat
      type: type
      depthBuffer: false
      stencilBuffer: false
    })]
    @renderTargets[1] = @renderTargets[0].clone()

    if commonGeometry?
      planeGeometry = commonGeometry
    else
      planeGeometry = new THREE.PlaneGeometry(100, 100)

    @mesh = new THREE.Mesh planeGeometry, @initShaderMaterial
    @mesh.material.needsUpdate = true

    @scene = new THREE.Scene()
    @scene.add @mesh

    @reset()


  reset: ->
    @mesh.material = @initShaderMaterial

    @renderer.render @scene, @camera, @renderTargets[0]
    @renderer.render @scene, @camera, @renderTargets[1]

    # @initShaderMaterial.dispose()
    # @initShaderMaterial = null

    @mesh.material = @updateShaderMaterial
    @mesh.material.needsUpdate = true
    return


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

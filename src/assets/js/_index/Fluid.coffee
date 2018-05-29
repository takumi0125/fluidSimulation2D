import RenderTexture from './RenderTexture'

export default class Fluid
  constructor: (@devicePixelRatio, @renderer, @camera)->


  init: (imgPath, width, height)->
    # 各種変数
    @dataTexPixelRatio = 0.4      # データテクスチャのピクセル比
    @solverIteration = 20         # 圧力計算の回数
    @attenuation = 1.00           # 圧力のステップごとの減衰値
    @alpha = 1.0                  # 圧力計算時の係数
    @beta = 1.0                   # 圧力計算時の係数
    @viscosity = 1                # 粘度
    @forceRadius = 90             # 加える力の半径
    @forceCoefficient = 1         # 加える力の係数
    @autoforceCoefficient = 0.01  # 自動で加える力の係数

    commonGeometry = new THREE.PlaneGeometry 10, 10

    # シェーダマテリアルを初期化
    @shaderMaterials =

      # 描画
      render: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require("./_glsl/render.frag")
        depthTest: false
        depthWrite: false
        transparent: true
        uniforms:
          time            : { type: '1f', value: 0 }
          texPixelRatio   : { type: '1f', value: @dataTexPixelRatio }
          dataTex         : { type:  't', value: null }
          outputImgTex    : { type:  't', value: null }
          resolution      : { type: '2f', value: null }
          devicePixelRatio: { type: '1f', value: @devicePixelRatio }

      # updateDivergence: 発散を計算
      updateDivergence: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require('./_glsl/updateDivergence.frag')
        depthTest: false
        depthWrite: false
        uniforms:
          texPixelRatio: { type: '1f', value: @dataTexPixelRatio }
          resolution   : { type: '2f', value: null }
          dataTex      : { type:  't', value: null }

      # updatePressure: 圧力を計算
      updatePressure: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require('./_glsl/updatePressure.frag')
        depthTest: false
        depthWrite: false
        uniforms:
          texPixelRatio: { type: '1f', value: @dataTexPixelRatio }
          resolution   : { type: '2f', value: null }
          dataTex      : { type:  't', value: 0 }
          alpha        : { type: '1f', value: @alpha }
          beta         : { type: '1f', value: @beta }

      # updateVelocity: 速度を計算
      updateVelocity: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require('./_glsl/updateVelocity.frag')
        depthTest: false
        depthWrite: false
        uniforms:
          time                : { type: '1f', value: 0 }
          texPixelRatio       : { type: '1f', value: @dataTexPixelRatio }
          viscosity           : { type: '1f', value: @viscosity }  # 粘度
          forceRadius         : { type: '1f', value: @forceRadius }
          forceCoefficient    : { type: '1f', value: @forceCoefficient }
          autoforceCoefficient: { type: '1f', value: @autoforceCoefficient }
          resolution          : { type: '2f', value: null }
          dataTex             : { type:  't', value: null }
          pointerPos          : { type: '2f', value: null }
          beforePointerPos    : { type: '2f', value: null }

      # advectData: データを伝搬
      advectData: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require('./_glsl/advectData.frag')
        depthTest: false
        depthWrite: false
        uniforms:
          resolution   : { type: '2f', value: null }
          texPixelRatio: { type: '1f', value: @dataTexPixelRatio }
          dataTex      : { type:  't', value: null }
          attenuation  : { type: '1f', value: @attenuation }  # 減衰

      # 画像描画
      renderImg: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require('./_glsl/renderImg.frag')
        depthTest: false
        depthWrite: false
        uniforms:
          time            : { type: '1f', value: 0 }
          texPixelRatio   : { type: '1f', value: @devicePixelRatio }
          dataTex         : { type:  't', value: null }
          outputImgTex    : { type:  't', value: null }
          resolution      : { type: '2f', value: new THREE.Vector2(width, height) }
          devicePixelRatio: { type: '1f', value: @devicePixelRatio }

      # 画像描画 イニシャライズ
      initRenderImg: new THREE.RawShaderMaterial
        vertexShader: require('./_glsl/common.vert')
        fragmentShader: require('./_glsl/initRenderImg.frag')
        depthTest: false
        depthWrite: false
        uniforms:
          time             : { type: '1f', value: 0 }
          texPixelRatio    : { type: '1f', value: @devicePixelRatio }
          tex              : { type:  't', value: null }
          texResolution    : { type: '2f', value: new THREE.Vector2() }
          resolution       : { type: '2f', value: new THREE.Vector2(width, height) }


    # RenderTexture dataTex
    initDataTexMaterial = new THREE.RawShaderMaterial(
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require('./_glsl/initData.frag')
      depthTest: false
      depthWrite: false
    )
    textureType = (if(/(iPad|iPhone|iPod)/g.test(navigator.userAgent)) then THREE.HalfFloatType else THREE.FloatType)
    @dataTex = new RenderTexture(
      Math.round(width * @dataTexPixelRatio)
      Math.round(height * @dataTexPixelRatio)
      @renderer
      @camera
      initDataTexMaterial
      initDataTexMaterial.clone()
      textureType
      commonGeometry
    )

    # mesh
    @mesh = new THREE.Mesh commonGeometry, @shaderMaterials.render

    # RenderTexture outputImgTex
    return new Promise (resolve)=>
      new THREE.TextureLoader().load imgPath, (texture)=>
        texture.wrapS = THREE.RepeatWrapping
        texture.wrapT = THREE.RepeatWrapping

        @setShaderUniform 'initRenderImg', 'tex', texture
        @setShaderUniform 'initRenderImg', 'texResolution', new THREE.Vector2(texture.image.width, texture.image.height)

        @setShaderUniform 'renderImg', 'outputImgTex', texture
        @setShaderUniform 'renderImg', 'dataTex', @dataTex.getTexture()

        texture.needsUpdate = true

        @outputImgTex = new RenderTexture(
          width
          height
          @renderer
          @camera
          @shaderMaterials.initRenderImg
          @shaderMaterials.renderImg
          textureType
          commonGeometry
        )
        # @setShaderUniform 'renderImg', 'outputImgTex', @outputImgTex.getTexture()
        @setShaderUniform 'render', 'outputImgTex', @outputImgTex.getTexture()
        resolve()


  # 各種パラメータを設定
  setParameters: ->
    @setShaderUniform 'updateDivergence', 'texPixelRatio', @dataTexPixelRatio
    @setShaderUniform 'updatePressure',   'texPixelRatio', @dataTexPixelRatio
    @setShaderUniform 'updateVelocity',   'texPixelRatio', @dataTexPixelRatio
    @setShaderUniform 'advectData',       'texPixelRatio', @dataTexPixelRatio

    @setShaderUniform 'advectData', 'attenuation', @attenuation

    @setShaderUniform 'updatePressure', 'alpha', @alpha
    @setShaderUniform 'updatePressure', 'beta', @beta

    @setShaderUniform 'updateVelocity', 'viscosity', @viscosity
    @setShaderUniform 'updateVelocity', 'forceRadius', @forceRadius
    @setShaderUniform 'updateVelocity', 'forceCoefficient', @forceCoefficient
    @setShaderUniform 'updateVelocity', 'autoforceCoefficient', @autoforceCoefficient

    return



  # データを更新
  updateData: (name)->
    @setShaderUniform name, 'dataTex', @dataTex.getTexture()
    @dataTex.swapTexture()
    @dataTex.setMeshMaterial @shaderMaterials[name]
    @renderer.render @dataTex.scene, @dataTex.camera, @dataTex.getRenderTarget()
    return


  # set shader uniform
  setShaderUniform: (name, key, value)->
    @shaderMaterials[name].uniforms[key]?.value = value
    @shaderMaterials[name].needsUpdate = true
    return


  update: (time, pointerPos, beforePointerPos)=>
    # 発散のバッファを更新
    @updateData 'updateDivergence'

    # 圧力のバッファを更新
    for i in [0...@solverIteration] then @updateData 'updatePressure'

    # 速度のバッファを更新
    @setShaderUniform 'updateVelocity', 'time', time
    @setShaderUniform 'updateVelocity', 'pointerPos', pointerPos
    @setShaderUniform 'updateVelocity', 'beforePointerPos', beforePointerPos
    @updateData 'updateVelocity'

    # データを伝播
    @updateData 'advectData'

    # img更新
    @setShaderUniform 'renderImg', 'outputImgTex', @outputImgTex.getTexture()
    @outputImgTex.swapTexture()
    @setShaderUniform 'renderImg', 'time', time
    @setShaderUniform 'renderImg', 'dataTex', @dataTex.getTexture()
    @renderer.render @outputImgTex.scene, @outputImgTex.camera, @outputImgTex.getRenderTarget()

    # 描画
    @setShaderUniform 'render', 'time', time
    @setShaderUniform 'render', 'dataTex', @dataTex.getTexture()
    @setShaderUniform 'render', 'outputImgTex', @outputImgTex.getTexture()
    return


  reset: ->




  # resize
  resize: (width, height)=>
    for name, material of @shaderMaterials
      @setShaderUniform name, 'resolution', new THREE.Vector2(width, height)

    texWidth = Math.round(width * @dataTexPixelRatio)
    texHeight = Math.round(height * @dataTexPixelRatio)

    @dataTex.resize texWidth, texHeight
    @dataTex.reset()

    if @outputImgTex?
      @outputImgTex.resize width * @devicePixelRatio, height * @devicePixelRatio
      @outputImgTex.reset()

    return

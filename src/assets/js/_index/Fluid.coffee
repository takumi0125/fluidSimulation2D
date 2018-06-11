import RenderTexture from './RenderTexture'
import map from '../_utils/math/map'

export default class Fluid
  constructor: (devicePixelRatio, @renderer, camera)->
    # 各種変数
    @texPixelRatio = 0.4          # ピクセル比
    @solverIteration = 20         # 圧力計算の回数
    @attenuation = 1.00           # 圧力のステップごとの減衰値
    @alpha = 1.0                  # 圧力計算時の係数
    @beta = 1.0                   # 圧力計算時の係数
    @viscosity = 0.99             # 粘度
    @forceRadius = 10             # 加える力の半径
    @forceCoefficient = 1         # 加える力の係数
    @velocityTimeScale = 1        # 速度のタイムスケール

    @spirographVertices = 3       # スピログラフの頂点数
    @spirographRadius1 = 100      # スピログラフの多角形の半径
    @spirographRadius2 = 10       # スピログラフの動円の半径
    @circleTimeScale = 2          # スピログラフの動円のタイムスケール

    # シェーダマテリアルを初期化
    @shaders = {}

    @shaders.render = new THREE.RawShaderMaterial
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require("./_glsl/render.frag")
      depthTest: false
      depthWrite: false
      uniforms:
        time            : { type: '1f', value: 0 }
        texPixelRatio   : { type: '1f', value: @texPixelRatio }
        dataTex         : { type:  't', value: null }
        resolution      : { type: '2f', value: null }
        devicePixelRatio: { type: '1f', value: devicePixelRatio }

    # updateDivergence: 発散を計算
    @shaders.updateDivergence = new THREE.RawShaderMaterial
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require('./_glsl/updateDivergence.frag')
      uniforms:
        texPixelRatio: { type: '1f', value: @texPixelRatio }
        resolution   : { type: '2f', value: null }
        dataTex      : { type:  't', value: null }

    # updatePressure: 圧力を計算
    @shaders.updatePressure = new THREE.RawShaderMaterial
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require('./_glsl/updatePressure.frag')
      uniforms:
        texPixelRatio: { type: '1f', value: @texPixelRatio }
        resolution   : { type: '2f', value: null }
        dataTex      : { type:  't', value: 0 }
        alpha        : { type: '1f', value: @alpha }
        beta         : { type: '1f', value: @beta }

    # updateVelocity: 速度を計算
    @shaders.updateVelocity = new THREE.RawShaderMaterial
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require('./_glsl/updateVelocity.frag')
      uniforms:
        time                : { type: '1f', value: 0 }
        velocityTimeScale   : { type: '1f', value: @velocityTimeScale }
        texPixelRatio       : { type: '1f', value: @texPixelRatio }
        viscosity           : { type: '1f', value: @viscosity }  # 粘度
        forceRadius         : { type: '1f', value: @forceRadius }
        forceCoefficient    : { type: '1f', value: @forceCoefficient }
        resolution          : { type: '2f', value: null }
        dataTex             : { type:  't', value: null }
        spirographVertices  : { type: '1f', value: @spirographVertices }
        spirographRadius1   : { type: '1f', value: @spirographRadius1 }
        spirographRadius2   : { type: '1f', value: @spirographRadius2 }
        circleTimeScale     : { type: '1f', value: @circleTimeScale }

    # advectData: データを伝搬
    @shaders.advectData = new THREE.RawShaderMaterial
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require('./_glsl/advectData.frag')
      uniforms:
        resolution   : { type: '2f', value: null }
        texPixelRatio: { type: '1f', value: @texPixelRatio }
        dataTex      : { type:  't', value: null }
        attenuation  : { type: '1f', value: @attenuation }  # 減衰

    # RenderTexture
    initMaterial = new THREE.RawShaderMaterial(
      vertexShader: require('./_glsl/common.vert')
      fragmentShader: require('./_glsl/initData.frag')
      depthTest: false
      depthWrite: false
    )
    @dataTexture = new RenderTexture(
      100
      100
      @renderer
      camera
      initMaterial
      initMaterial.clone()
    )

    geometry = new THREE.PlaneGeometry 100, 100

    # mesh
    @mesh = new THREE.Mesh geometry, @shaders.render

    gui = new dat.GUI()

    gui.add @, 'texPixelRatio', 0.01, 1
    .onChange (value)=>
      @setShaderUniform 'updateDivergence', 'texPixelRatio', value
      @setShaderUniform 'updatePressure',   'texPixelRatio', value
      @setShaderUniform 'updateVelocity',   'texPixelRatio', value
      @setShaderUniform 'advectData',       'texPixelRatio', value
      @dataTexture.resize Math.round(@width * value), Math.round(@height * value)
      return

    gui.add @, 'viscosity', 0.8, 1
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'viscosity', value

    gui.add @, 'forceRadius', 1, 100
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'forceRadius', value

    gui.add @, 'forceCoefficient', 0.01, 10
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'forceCoefficient', value

    gui.add(@, 'spirographVertices', 3, 12).step(1)
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'spirographVertices', Math.round(value)

    gui.add @, 'spirographRadius1', 30, 400
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'spirographRadius1', value
    gui.add @, 'spirographRadius2', 6, 100
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'spirographRadius2', value

    gui.add @, 'circleTimeScale', 0, 10
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'circleTimeScale', value

    gui.add @, 'velocityTimeScale', 0, 1
    .onChange (value)=> @setShaderUniform 'updateVelocity', 'velocityTimeScale', value

    return


  # 各種パラメータを設定
  setParameters: ->
    @setShaderUniform 'updateDivergence', 'texPixelRatio', @texPixelRatio
    @setShaderUniform 'updatePressure',   'texPixelRatio', @texPixelRatio
    @setShaderUniform 'updateVelocity',   'texPixelRatio', @texPixelRatio
    @setShaderUniform 'advectData',       'texPixelRatio', @texPixelRatio

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
    @setShaderUniform name, 'dataTex', @dataTexture.getTexture()
    @dataTexture.swapTexture()
    @dataTexture.setMeshMaterial @shaders[name]
    @renderer.render @dataTexture.scene, @dataTexture.camera, @dataTexture.getRenderTarget()
    return


  # set shader uniform
  setShaderUniform: (name, key, value)->
    @shaders[name].uniforms[key].value = value
    return


  update: (time)=>
    # 発散のバッファを更新
    @updateData 'updateDivergence'

    # 圧力のバッファを更新
    for i in [0...@solverIteration] then @updateData 'updatePressure'

    # 速度のバッファを更新
    @setShaderUniform 'updateVelocity', 'time', time
    @updateData 'updateVelocity'

    # データを伝播
    @updateData 'advectData'

    # 描画
    @setShaderUniform 'render', 'time'   , time
    @setShaderUniform 'render', 'dataTex', @dataTexture.getTexture()
    return


  # resize
  resize: (@width, @height)=>
    for name, material of @shaders
      @setShaderUniform name, 'resolution', new THREE.Vector2(@width, @height)

    @dataTexture.resize Math.round(@width * @texPixelRatio), Math.round(@height * @texPixelRatio)
    return

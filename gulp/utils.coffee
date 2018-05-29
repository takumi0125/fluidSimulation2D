#############
### utils ###
#############

buffer        = require 'vinyl-buffer'
mergeStream   = require 'merge-stream'
source        = require 'vinyl-source-stream'
webpackStream = require 'webpack-stream'
webpack       = require 'webpack'


module.exports = (gulp, gulpPlugins, config)->
  utils =
    #
    # spritesmith のタスクを生成
    #
    # @param {String}  taskName      タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {String}  imgDir        ソース画像ディレクトリへのパス (ドキュメントルートからの相対パス)
    # @param {String}  cssDir        ソースCSSディレクトリへのパス (ドキュメントルートからの相対パス)
    # @param {String}  outputImgName 指定しなければ#{taskName}.pngになる
    # @param {String}  outputImgPath CSSに記述される画像パス (相対パスの際に指定する)
    # @param {Boolean} compressImg   画像を圧縮するかどうか
    #
    # #{config.srcDir}#{imgDir}/_#{taskName}/
    # 以下にソース画像を格納しておくと
    # #{config.srcDir}#{cssDir}/_#{taskName}.scss と
    # #{config.srcDir}#{imgDir}/#{taskName}.png が生成される
    # かつ watch タスクの監視も追加
    #
    createSpritesTask: (taskName, imgDir, cssDir, outputImgName = '', outputImgPath = '', compressImg = false) ->
      config.spritesTaskNames.push taskName

      srcImgFiles = "#{config.srcDir}/#{imgDir}/#{config.excrusionPrefix}#{taskName}/*"
      config.filePath.img.push "!#{srcImgFiles}"

      gulp.task taskName, ->

        spriteObj =
          imgName: "#{outputImgName or taskName}.png"
          cssName: "#{config.excrusionPrefix}#{taskName}.scss"
          algorithm: 'binary-tree'
          padding: 2
          # cssOpts:
          #   variableNameTransforms: ['camelize']

        if outputImgPath then spriteObj.imgPath = outputImgPath

        spriteData = gulp.src srcImgFiles
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler taskName
        .pipe gulpPlugins.spritesmith spriteObj

        imgStream = spriteData.img

        imgStream
        .pipe gulp.dest "#{config.srcDir}/#{imgDir}"
        .pipe gulp.dest "#{config.publishDir}/#{imgDir}"

        cssStream = spriteData.css.pipe gulp.dest "#{config.srcDir}/#{cssDir}"

        return mergeStream imgStream, cssStream

      config.optionsWatchTasks.unshift -> gulpPlugins.watch(srcImgFiles, -> gulp.start [ taskName ])

    #
    # webpackのタスクを生成 (coffeescript, babel[es2015], glsl使用)
    #
    # @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {Array|String} entries         browserifyのentriesオプションに渡す node-globのシンタックスで指定
    # @param {Array|String} src             entriesを除いた全ソースファイル (watchタスクで監視するため) node-globのシンタックスで指定
    # @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
    # @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
    #
    # entries以外のソースファイルを指定する理由は、watchの監視の対象にするためです。
    # 複数の entry ファイルに対応していません。1タスクごとに1JSファイルがアウトプットされます。
    #
    createWebpackJsTask: (taskName, entries, src, outputDir, outputFileName) ->
      config.jsConcatTaskNames.push taskName

      webpackConfig =
        entry: entries
        output:
          path: outputDir
          filename: "#{outputFileName}.js"
        module:
          rules: [
            {
              test: /\.coffee$/
              exclude: [/\/node_modules\//, /\/bower_components\//, /\/htdocs\//, /\/gulp\//, /\/\.cache-loader\//]
              use: [
                { loader: 'cache-loader' }
                {
                  loader: 'babel-loader'
                  options:
                    presets: [
                      [ 'env', { 'modules': false } ]
                    ]
                    plugins: ['transform-runtime']
                }
                {
                  loader: 'coffee-loader'
                  options: { presets: [ 'react' ] }
                }
              ]
            }
            {
              test: /\.(js|es|es6)$/
              exclude: [/\/node_modules\//, /\/bower_components\//, /\/htdocs\//, /\/gulp\//, /\/\.cache-loader\//]
              use: [
                { loader: 'cache-loader' }
                {
                  loader: 'babel-loader'
                  options:
                    presets: [
                      [ 'env', { 'modules': false } ]
                      'react'
                    ]
                    plugins: ['transform-runtime']
                }
              ]
            }
            { test: /\.(html|json|glsl|vert|frag)$/, use: [{ loader: 'raw-loader' }] }
            { test: /\.(glsl|vert|frag)$/, use: [{ loader: 'glslify-loader' }] }
          ]
        externals:
          "react": 'React'
          "react-dom": 'ReactDOM'

        plugins: []
        resolve:
          extensions: [ '.js', '.json', '.coffee', '.es', '.es6', '.glsl', '.vert', '.frag' ]

      gulp.task taskName, ->
        if config.sourcemap
          webpackConfig.devtool = 'source-map'

        if config.compress.js and config.env isnt 'develop'
          uglifyJsPluginOptions =
            parallel: true
            comments: false

          if config.sourcemap then uglifyJsPluginOptions.sourceMap = true

          webpackConfig.plugins.push new webpack.optimize.UglifyJsPlugin uglifyJsPluginOptions

        stream = gulp.src entries
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler taskName
        .pipe webpackStream webpackConfig, null, (e, stats)->

        stream.pipe gulp.dest outputDir

      config.optionsWatchTasks.push -> gulpPlugins.watch entries.concat(src), -> gulp.start [ taskName ]


    #
    # javascriptのconcatタスクを生成
    #
    # @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
    # @param {Array|String} src             ソースパス node-globのシンタックスで指定
    # @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
    # @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
    #
    createJsConcatTask: (taskName, src, outputDir, outputFileName = 'lib')->
      config.jsConcatTaskNames.push taskName

      gulp.task taskName, ->
        stream = gulp.src src
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler taskName

        if config.sourcemap
          stream = stream
          .pipe gulpPlugins.sourcemaps.init()
          .pipe gulpPlugins.concat "#{outputFileName}.js"
          .pipe gulpPlugins.uglify { output: {comments: 'some'} }
          .pipe gulpPlugins.sourcemaps.write '.'
        else
          stream = stream
          .pipe gulpPlugins.concat "#{outputFileName}.js"
          .pipe gulpPlugins.uglify { output: {comments: 'some'} }

        stream
        .pipe gulp.dest outputDir
        .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan("[#{taskName}]")

      config.optionsWatchTasks.push -> gulpPlugins.watch src, -> gulp.start [ taskName ]


    #
    # エラー出力
    #
    errorHandler: (name)-> gulpPlugins.notify.onError title: "#{name} Error", message: '<%= error.message %>'


    #
    # タスク対象のファイル、ディレクトリの配列を生成
    #
    createSrcArr: (name)->
      [].concat config.filePath[name], [
        "!#{config.srcDir}/**/#{config.excrusionPrefix}*"
        "!#{config.srcDir}/**/#{config.excrusionPrefix}*/"
        "!#{config.srcDir}/**/#{config.excrusionPrefix}*/**"
      ]


    #
    # gulpのログの形式でconsole.log
    #
    msg: (msg)->
      d = new Date()
      console.log "[#{gulpPlugins.util.colors.gray(d.getHours() + ':' + d.getMinutes() + ':' + d.getSeconds())}] #{msg}"


    #
    # PostCSS
    #
    postCSS: (stream)->
      postCSSOptions = [
        require('autoprefixer')({ browsers: config.autoprefixerOpt })
      ]

      if config.compress.css and config.env isnt 'develop'
        postCSSOptions.push require('cssnano')({ autoprefixer: false, zindex: false })

      return stream.pipe gulpPlugins.postcss(postCSSOptions)

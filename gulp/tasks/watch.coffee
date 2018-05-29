#############
### watch ###
#############

connectSSI = require 'connect-ssi'

module.exports = (gulp, gulpPlugins, config, utils)->
  gulp.task 'watch', config.watchifyTaskNames, ->
    # config.pugData更新時
    gulpPlugins.watch config.pugData, -> gulp.start [ 'pugAll' ]

    gulpPlugins.watch utils.createSrcArr('html'),   -> gulp.start [ 'copyHtml' ]
    gulpPlugins.watch utils.createSrcArr('css'),    -> gulp.start [ 'copyCss' ]
    gulpPlugins.watch utils.createSrcArr('js'),     -> gulp.start [ 'copyJs' ]
    gulpPlugins.watch utils.createSrcArr('json'),   -> gulp.start [ 'copyJson' ]
    gulpPlugins.watch utils.createSrcArr('img'),    -> gulp.start [ 'copyImg' ]
    gulpPlugins.watch utils.createSrcArr('others'), -> gulp.start [ 'copyOthers' ]
    gulpPlugins.watch utils.createSrcArr('pug'),    -> gulp.start [ 'pug' ]
    gulpPlugins.watch utils.createSrcArr('sass'),   -> gulp.start [ 'sass' ]
    gulpPlugins.watch utils.createSrcArr('stylus'), -> gulp.start [ 'stylus' ]

    # インクルードファイル(アンスコから始まるファイル)更新時はすべてをコンパイル
    gulpPlugins.watch config.filePath.pugInclude,    -> gulp.start [ 'pugAll' ]
    gulpPlugins.watch config.filePath.sassInclude,   -> gulp.start [ 'sassAll' ]
    gulpPlugins.watch config.filePath.stylusInclude, -> gulp.start [ 'stylusAll' ]

    for task in config.optionsWatchTasks then task()

    gulp.src config.publishDir
    .pipe gulpPlugins.webserver
      livereload:
        enable: true
        filter: (fileName)-> return !fileName.match(/.map$/)
      port: 50000
      open: config.serverDefaultPath
      directoryListing: true
      host: '0.0.0.0'
      https: config.https
      middleware:
        connectSSI
          baseDir: config.publishDir
          ext: '.html'
    .pipe gulpPlugins.notify "[watch]: start local server. http://localhost:50000#{config.serverDefaultPath}"

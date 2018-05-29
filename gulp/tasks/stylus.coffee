##############
### stylus ###
##############

module.exports = (gulp, gulpPlugins, config, utils)->
  # stylus
  gulp.task 'stylus', ->
    stream = gulp.src utils.createSrcArr 'stylus'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.css' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'stylus'

    if config.sourcemap
      stream = stream
      .pipe gulpPlugins.sourcemaps.init()
      .pipe gulpPlugins.stylus('include css': true)
      .pipe gulpPlugins.sourcemaps.write()
      .pipe gulpPlugins.sourcemaps.init loadMaps: true
      stream = utils.postCSS stream
      .pipe gulpPlugins.sourcemaps.write '.'
    else
      stream = stream.pipe gulpPlugins.sass outputStyle: 'expanded'
      stream = utils.postCSS stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[stylus]:')


  # stylusAll
  gulp.task 'stylusAll', ->
    stream = gulp.src utils.createSrcArr 'stylus'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'stylus'

    if config.sourcemap
      stream = stream
      .pipe gulpPlugins.sourcemaps.init()
      .pipe gulpPlugins.stylus('include css': true)
      .pipe gulpPlugins.sourcemaps.write()
      .pipe gulpPlugins.sourcemaps.init loadMaps: true
      stream = utils.postCSS stream
      .pipe gulpPlugins.sourcemaps.write '.'
    else
      stream = stream.pipe gulpPlugins.sass outputStyle: 'expanded'
      stream = utils.postCSS stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[stylusAll]:')

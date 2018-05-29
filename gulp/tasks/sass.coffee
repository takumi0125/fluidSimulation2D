############
### sass ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  # sass
  gulp.task 'sass', ->
    stream = gulp.src utils.createSrcArr 'sass'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.css' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'sass'

    if config.sourcemap
      stream = stream
      .pipe gulpPlugins.sourcemaps.init()
      .pipe gulpPlugins.sass outputStyle: 'expanded'
      .pipe gulpPlugins.sourcemaps.write()
      .pipe gulpPlugins.sourcemaps.init loadMaps: true
      stream = utils.postCSS stream
      .pipe gulpPlugins.sourcemaps.write '.'
    else
      stream = stream.pipe gulpPlugins.sass outputStyle: 'expanded'
      stream = utils.postCSS stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[sass]:')


  # sassAll
  gulp.task 'sassAll', ->
    stream = gulp.src utils.createSrcArr 'sass'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'sass'

    if config.sourcemap
      stream = stream
      .pipe gulpPlugins.sourcemaps.init()
      .pipe gulpPlugins.sass outputStyle: 'expanded'
      .pipe gulpPlugins.sourcemaps.write()
      .pipe gulpPlugins.sourcemaps.init loadMaps: true
      stream = utils.postCSS stream
      .pipe gulpPlugins.sourcemaps.write '.'
    else
      stream = stream.pipe gulpPlugins.sass outputStyle: 'expanded'
      stream = utils.postCSS stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[sassAll]:')

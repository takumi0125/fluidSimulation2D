############
### pug ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  pugOptions =
    basedir: config.srcDir
    pretty: true

  if config.compress.html and config.env isnt 'develop'
    pugOptions.pretty = false

  # pug
  gulp.task 'pug', ->
    gulp.src utils.createSrcArr 'pug'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.html' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'pug'
    .pipe gulpPlugins.data ->
      data = require(config.pugData)(config.env)
      return data
    .pipe gulpPlugins.pug(pugOptions)
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[pug]:')

  # pugAll
  gulp.task 'pugAll', ->
    gulp.src utils.createSrcArr 'pug'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'pugAll'
    .pipe gulpPlugins.data ->
      data = require(config.pugData)(config.env)
      return data
    .pipe gulpPlugins.pug(pugOptions)
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[pugAll]:')

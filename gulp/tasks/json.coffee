############
### json ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  # jsonlint
  gulp.task 'jsonlint', ->
    gulp.src utils.createSrcArr 'json'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'jsonlint'
    .pipe gulpPlugins.jsonlint()
    .pipe gulpPlugins.jsonlint.reporter()
    .pipe gulpPlugins.notify (file)-> if file.jsonlint.success then false else 'jsonlint error'

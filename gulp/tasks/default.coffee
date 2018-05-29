###############
### default ###
###############

runSequence = require 'run-sequence'
notifier    = require 'node-notifier'

module.exports = (gulp, gulpPlugins, config, utils)->
  gulp.task 'default', [ 'clean' ], ->
    runSequence [ 'json', 'sprites', 'jsEnv' ], [ 'html', 'css', 'js', 'copyImg', 'copyOthers' ], ->
      utils.msg gulpPlugins.util.colors.yellow '\n====================\n build complete !!\n===================='
      notifier.notify title: 'gulp', message: 'build complete!!'

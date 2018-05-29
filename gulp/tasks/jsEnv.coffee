##############
### jsEnv ###
##############

module.exports = (gulp, gulpPlugins, config, utils)->
  # coffee
  fs = require('fs')
  gulp.task 'jsEnv', (callback) ->
    data = require(config.pugData)(config.env)
    jsEnv =
      env: config.env
    code = 'module.exports = ' + JSON.stringify(jsEnv, null, '  ')
    fs.writeFileSync(config.jsEnv, code, 'utf8')
    callback()

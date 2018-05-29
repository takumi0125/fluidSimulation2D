##############
### config ###
##############

srcDir = "#{__dirname}/../src"

publishDir = "#{__dirname}/../htdocs"

excrusionPrefix = '_'

imgDirName = '{img,image,images}'

config =
  # ソースディレクトリ
  srcDir: srcDir,

  # 納品ディレクトリ
  publishDir: publishDir,

  # ローカルサーバのデフォルトパス (ドキュメントルートからの絶対パス)
  serverDefaultPath: '/',

  # ローカルサーバをhttpsにするかどうか
  https: false

  # タスクから除外するためのプレフィックス
  excrusionPrefix: excrusionPrefix,

  # gulpPlugins.autoprefixerのオプション
  autoprefixerOpt: [ 'last 3 versions', 'ie 9', 'ie 10', 'Android 4', 'iOS 9' ],

  # assetsディレクトリへドキュメントルートからの相対パス
  assetsDir: 'assets',

  # 画像ディレクトリの名前
  imgDirName: imgDirName

  # ファイル圧縮
  compress:
    # CSSを圧縮するかどうか
    css: true

    # JSを圧縮するかどうか
    js: true

    # HTMLを圧縮するかどうか (pugのみ)
    html: true

  # pugで読み込むjsonファイル
  pugData: "#{__dirname}/../pugData.coffee"

  # JS設定ファイル
  jsEnv: "#{srcDir}/assets/js/#{excrusionPrefix}env.js"

  # publishDir内のclean対象のディレクトリ (除外したいパスがある場合にnode-globのシンタックスで指定)
  clearDir: [
    "#{publishDir}/**/*"
    "!#{publishDir}"
  ]

  # 各種パス
  filePath:
    html    : "#{srcDir}/**/*.html"
    pug     : "#{srcDir}/**/*.{pug,jade}"
    jade    : "#{srcDir}/**/*.{pug,jade}"
    css     : "#{srcDir}/**/*.css"
    sass    : "#{srcDir}/**/*.{sass,scss}"
    stylus  : "#{srcDir}/**/*.styl"
    js      : "#{srcDir}/**/*.js"
    json    : "#{srcDir}/**/*.json"
    json5   : "#{srcDir}/**/*.json5"
    coffee  : "#{srcDir}/**/*.coffee"
    cson    : "#{srcDir}/**/*.cson"
    img     : [
      "#{srcDir}/**/#{imgDirName}/**"
      "!#{srcDir}/**/font/**"
    ]
    others  : [
      "#{srcDir}/**/*"
      "#{srcDir}/**/.htaccess"
      "!#{srcDir}/**/*.{html,pug,jade,css,sass,scss,styl,js,json,coffee,cson,md,map}"
      "!#{srcDir}/**/#{imgDirName}/**"
    ]
    pugInclude: [
      "#{srcDir}/**/#{excrusionPrefix}*/**/*.pug"
      "#{srcDir}/**/#{excrusionPrefix}*.pug"
      "#{srcDir}/**/#{excrusionPrefix}*/**/*.jade"
      "#{srcDir}/**/#{excrusionPrefix}*.jade"
    ]
    jadeInclude: [
      "#{srcDir}/**/#{excrusionPrefix}*/**/*.pug"
      "#{srcDir}/**/#{excrusionPrefix}*.pug"
      "#{srcDir}/**/#{excrusionPrefix}*/**/*.jade"
      "#{srcDir}/**/#{excrusionPrefix}*.jade"
    ]
    sassInclude: [
      "#{srcDir}/**/#{excrusionPrefix}*/**/*.{sass,scss}"
      "#{srcDir}/**/#{excrusionPrefix}*.{sass,scss}"
    ]
    stylusInclude: [
      "#{srcDir}/**/#{excrusionPrefix}*/**/*.stylus"
      "#{srcDir}/**/#{excrusionPrefix}*.stylus"
    ]



module.exports = config

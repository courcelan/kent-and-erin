#    .aMMMb  .dMMMb  .dMMMb
#   dMP"VMP dMP" VP dMP" VP
#  dMP      VMMMb   VMMMb
# dMP.aMP dP .dMP dP .dMP
# VMMMP"  VMMMP"  VMMMP"

utils = require 'gulp-util'
colors = require('gulp-util').colors
helpers = require './helpers.coffee'

# PostCSS plugins
autoprefixer = require 'autoprefixer'
mq = require 'css-mqpacker'
cssnano = require 'cssnano'

module.exports = (gulp, plugins, config) ->
    () ->
        if config.shopify
            config.stylus.destination = config.stylus.shopify

        gulp.src(
            config.stylus.glob
            cwd: "./#{ config.source }/#{ config.stylus.cwd }"
        )
        .pipe( plugins.plumber() )
        .pipe(
            plugins.stylus(
                compress: false
                log: true
                cache: false
                showFiles: true
                # import: ["#{__dirname}/../../#{ config.stylus.framework.cwd }/*"]
            )
        )
        .pipe(
            plugins.if(
                config.unminify
                plugins.postcss([
                    autoprefixer( browsers: config.stylus.autoprefixer )
                    mq( sort: true )
                ])
                plugins.postcss([
                    autoprefixer( browsers: config.stylus.autoprefixer )
                    mq( sort: true )
                    cssnano( )
                ])
            )
        )
        # .pipe(
        #     plugins.if(
        #         config.dataURI
        #         plugins.imageEmbed(
        #             asset: "#{ config.assets.destination }"
        #             extension: ['jpg', 'png', 'gif', 'svg']
        #         )
        #         utils.noop()
        #     )
        # )
        .pipe( plugins.sizereport( gzip: true ) )
        .pipe( gulp.dest( config.stylus.destination ) )
        .pipe(
            utils.noop(
                helpers.console_onComplete(
                    "Stylus »»» CSS",
                    config.stylus.destination
                )
            )
        )

#   dMP dMP dMMMMMP dMMMMb  dMMMMb  .aMMMb  dMMMMb
#  dMP dMP dMP     dMP dMP dMP VMP dMP"dMP dMP.dMP
# dMP dMP dMMMP   dMP dMP dMP dMP dMP dMP dMMMMK"
# YMvAP" dMP     dMP dMP dMP.aMP dMP.aMP dMP"AMF
#  VP"  dMMMMMP dMP dMP dMMMMP"  VMMMP" dMP dMP

utils = require 'gulp-util'
colors = require('gulp-util').colors
helpers = require './helpers.coffee'

module.exports = (gulp, plugins, config) ->
    () ->
        if config.shopify
            config.vendor.destination = config.vendor.shopify

        gulp.src(
            config.vendor.glob
            cwd: "./#{config.source}/#{config.vendor.cwd}"
        )
        .pipe(
            plugins.if(
                config.force || !config.local,
                utils.noop(),
                plugins.changed( config.vendor.destination )
            )
        )
        .pipe( plugins.imagemin() )
        .pipe( plugins.uglify() )
        .pipe( gulp.dest( config.vendor.destination ) )
        .pipe(
            utils.noop(
                helpers.console_onComplete(
                    "Vendor Assets »»» Production",
                    config.vendor.destination
                )
            )
        )

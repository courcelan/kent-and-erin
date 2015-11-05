#     .aMMMb  .dMMMb  .dMMMb  dMMMMMP dMMMMMMP .dMMMb
#    dMP"dMP dMP" VP dMP" VP dMP        dMP   dMP" VP
#   dMMMMMP  VMMMb   VMMMb  dMMMP      dMP    VMMMb
#  dMP dMP dP .dMP dP .dMP dMP        dMP   dP .dMP
# dMP dMP  VMMMP"  VMMMP" dMMMMMP    dMP    VMMMP"

utils = require 'gulp-util'
colors = require('gulp-util').colors
helpers = require './helpers.coffee'

module.exports = (gulp, plugins, config) ->
    () ->
        if config.shopify
            config.assets.destination = config.assets.shopify

        gulp.src(
            config.assets.glob
            cwd: "./#{ config.source }/#{ config.assets.cwd }"
        )
        .pipe(
            plugins.if(
                config.force || !config.local,
                utils.noop(),
                plugins.changed( config.assets.destination )
            )
        )
        .pipe( plugins.imagemin() )
        .pipe( gulp.dest( config.assets.destination ) )
        .pipe(
            utils.noop(
                helpers.console_onComplete(
                    "Assets »»» Production",
                    config.assets.destination
                )
            )
        )

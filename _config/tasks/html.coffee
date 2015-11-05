#     dMP dMP dMMMMMMP dMMMMMMMMb  dMP
#    dMP dMP    dMP   dMP"dMP"dMP dMP
#   dMMMMMP    dMP   dMP dMP dMP dMP
#  dMP dMP    dMP   dMP dMP dMP dMP
# dMP dMP    dMP   dMP dMP dMP dMMMMMP

utils = require 'gulp-util'
colors = require('gulp-util').colors
helpers = require './helpers.coffee'

module.exports = (gulp, plugins, config) ->
    local_source = "./#{ config.source }/#{ config.html.cwd }"

    () ->
        gulp.src(
            config.html.glob,
            cwd: local_source
        )
        .pipe( plugins.plumber() )
        .pipe(
            plugins.if(
                config.force,
                utils.noop(),
                plugins.changed(
                    config.html.destination,
                    ext: ".html"
                )
            )
        )
        .pipe( gulp.dest( "#{ config.html.destination }" ) )
        .pipe(
            utils.noop(
                helpers.console_onComplete(
                    "HTML »»» HTML (browser-synced)",
                    config.html.destination
                )
            )
        )

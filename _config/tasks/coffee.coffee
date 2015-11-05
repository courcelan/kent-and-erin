#    dMMMMMP .dMMMb
#       dMP dMP" VP
#      dMP  VMMMb
# dK .dMP dP .dMP
# VMMMP"  VMMMP"

utils = require 'gulp-util'
colors = require('gulp-util').colors
helpers = require './helpers.coffee'

lint_opts = # Coffeescript lint options
    arrow_spacing: true
    no_empty_param_list: true
    no_implicit_braces: true
    space_operators: true
    max_line_length:
        value: 100
    indentation:
        value: 4

module.exports = (gulp, plugins, config) ->
    () ->
        if config.shopify
            config.coffee.destination = config.coffee.shopify

        gulp.src(
            config.coffee.glob
            cwd: "./#{ config.source }/#{ config.coffee.cwd }"
        )
        .pipe(
            plugins.if(
                config.force || !config.local,
                utils.noop(),
                plugins.newer(
                    "#{ config.coffee.destination }/#{config.coffee.output}"
                )
            )
        )
        .pipe( plugins.coffeelint( lint_opts ) )
        .pipe( plugins.coffeelint.reporter() )
        .pipe( plugins.sourcemaps.init() )
        .pipe(
            plugins.coffee( config.coffee )
                .on('error', utils.log)
        )
        .pipe(
            plugins.concat( config.coffee.output )
         )
        .pipe(
            plugins.if(
                config.unminify
                utils.noop()
                plugins.uglify()
            )
        )
        .pipe( plugins.sizereport( gzip: true ) )
        .pipe( plugins.sourcemaps.write( './maps' ) )
        .pipe( gulp.dest( config.coffee.destination ) )
        .pipe(
            utils.noop(
                helpers.console_onComplete(
                    "CoffeeScript »»» JS",
                    config.coffee.destination
                )
            )
        )

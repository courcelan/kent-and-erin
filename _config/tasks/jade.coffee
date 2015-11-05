#     dMP dMP dMMMMMMP dMMMMMMMMb  dMP
#    dMP dMP    dMP   dMP"dMP"dMP dMP
#   dMMMMMP    dMP   dMP dMP dMP dMP
#  dMP dMP    dMP   dMP dMP dMP dMP
# dMP dMP    dMP   dMP dMP dMP dMMMMMP
utils = require 'gulp-util'
colors = require('gulp-util').colors
helpers = require './helpers.coffee'

# make sure we have the most up-to-date Jade version, so lets supply our own
jade = require 'jade'

module.exports = (gulp, plugins, config, data) ->
    local_source = "./#{ config.source }/#{ config.jade.cwd }"
    vefa = require("#{__dirname}/../../#{ config.jade.framework.cwd }/index.coffee")(data)

    jade_locals = data
    jade_locals.vefa = vefa.functions
    for func of vefa.filters
        jade.filters[func] = vefa.filters[func]

    if config.shopify
        config.jade.destination = config.jade.shopify

    () ->
        gulp.src(
            config.jade.glob,
            cwd: local_source
        )
        .pipe( plugins.plumber() )
        .pipe(
            plugins.if(
                config.force,
                utils.noop(),
                plugins.changed(
                    config.jade.destination,
                    ext: ".html"
                )
            )
        )
        .pipe(
            plugins.jadeInheritance(
                basedir: local_source
            )
        )
        .pipe(
            plugins.jade(
                jade: jade
                basedir: local_source
                pretty: false
                compileDebug: false
                doctype: 'html'
                locals: jade_locals
                filters: vefa.filters
            )
        )
        # this allows us to use Jade to write the following
        # and then output as the correct file extension
        .pipe( plugins.extReplace(".svg", ".svg.html") )
        .pipe( plugins.extReplace(".xml", ".xml.html") )
        .pipe( plugins.extReplace(".md", ".md.html") )
        .pipe(
            plugins.if(
                config.shopify
                plugins.extReplace(".liquid", ".html")
                utils.noop()
            )
        )
        .pipe( gulp.dest( config.jade.destination ) )
        .pipe(
            utils.noop(
                helpers.console_onComplete(
                    "Jade »»» Django/Liquid HTML",
                    config.jade.destination
                )
            )
        )

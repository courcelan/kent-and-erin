# ==================================================================================================
# GULPFILE
# By: Wellfire Interactive, LLC (wellfire.co)
#
#
site_file = 'build.yaml'

#     dMP dMMMMb  dMP dMMMMMMP
#    amr dMP dMP amr    dMP
#   dMP dMP dMP dMP    dMP
#  dMP dMP dMP dMP    dMP
# dMP dMP dMP dMP    dMP
#
# LOAD DEPENDENCIES
#
require 'coffee-script/register'
gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
plugins.runSequence = require 'run-sequence'
utils = require 'gulp-util'
colors = require('gulp-util').colors
browserSync = require 'browser-sync'
browserReload = browserSync.reload
# for local testing static server: use divshot server (npm install -g divshot-cli)
helpers = require './tasks/helpers.coffee'

#    .aMMMb  .aMMMb  dMMMMb  dMMMMMP dMP .aMMMMP .dMMMb
#   dMP"VMP dMP"dMP dMP dMP dMP     amr dMP"    dMP" VP
#  dMP     dMP dMP dMP dMP dMMMP   dMP dMP MMP" VMMMb
# dMP.aMP dMP.aMP dMP dMP dMP     dMP dMP.dMP dP .dMP
# VMMMP"  VMMMP" dMP dMP dMP     dMP  VMMMP"  VMMMP"
site =
    build_config: {}

config = helpers.yaml_load("#{ __dirname }/#{ site_file }")

# start server
config.serve = if utils.env.serve then true else false
# start watch of files
config.watch = if utils.env.watch then true else false
# minify css and js
config.unminify = if utils.env.unminify then true else false
# force a full recompile
config.force = if utils.env.force then true else false
# open browsersync debug browsers
config.debug = if utils.env.debug then true else false
# force specific url to open within browsersync browsers
config.view = if utils.env.url then utils.env.url else false
# open the browsersync ui for use
config.ui = if utils.env.ui then "ui" else false
# convert CSS background images to data URIs, not always recommended, run size report
config.dataURI = if utils.env.datauri then true else false
# set up to build out a shopify environment
config.shopify = if utils.env.shopify then true else false
config.local = if utils.env.shopify then false else true


# add config to the site.build_config object for use within Jade/Stylus/Coffeescript
helpers.copy_config(config, site.build_config)
helpers.load_data(site, config)


get_task = (task, notify) ->
    helpers.bs_notify( notify ) if notify
    require("./tasks/#{task}.coffee")(gulp, plugins, config, site)





gulp.task 'default', ['build'], ->

gulp.task 'build', (cb) ->
    plugins.runSequence(
        ['assets', 'vendor'],
        ['css', 'js']
        'html',
        'browser-sync',
        cb
    )


gulp.task 'html', get_task("jade", "Jade »»» HTML")
# gulp.task 'templates', get_task("metalsmith", "Metalsmith »»» Jade »»» HTML Templates")
gulp.task 'css', get_task("stylus", "Stylus »»» CSS")
gulp.task 'js', get_task("coffee", "CoffeeScript »»» JS")
gulp.task 'assets', get_task("assets", "Assets »»» Production Assets")
gulp.task 'vendor', get_task("vendor", "Vendor Assets »»» Production Assets")

gulp.task 'html-watch', ["html"], browserReload
gulp.task 'css-watch', ["css"], browserReload
gulp.task 'js-watch', ["js"], browserReload


gulp.task 'browser-sync', ->
    if config.watch
        helpers.browser_sync(config)

        gulp.watch( "./#{ config.source }/#{config.jade.cwd}/**", [ 'html-watch' ] )
        gulp.watch( "./#{ config.source }/#{config.stylus.cwd}/**", [ 'css-watch' ] )
        gulp.watch( "./#{ config.source }/#{config.coffee.cwd}/**", [ 'js-watch' ] )

    if config.serve
        helpers.serve(config)


gulp.task 'serve', (cb) ->
    helpers.serve(config)
    cb()

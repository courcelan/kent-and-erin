colors = require('gulp-util').colors
fs = require 'fs'
yaml = require 'js-yaml'
browserSync = require 'browser-sync'
charge = require 'charge'
http = require 'http'

module.exports =
    console_onComplete: (type, dir) ->
        console.log(
            colors.yellow( colors.underline("[#{type}] output to:") ) +
            colors.gray("\u0020\u0020\u0020#{ dir }")
        )

    copy_config: (config, return_val) ->
        for key, value of config
            return_val[key] = value

    yaml_load: (file) ->
        yaml.safeLoad( fs.readFileSync(file, 'utf8') )

    load_data: (locals, config)->
        cwd = "./#{ config.source }/#{ config.data.cwd }"
        for file in fs.readdirSync( cwd )
            file_name = file.split(".")[0]
            if file_name
                locals[file_name] = {}
                temp = @yaml_load( "#{ cwd }/#{ file }" )
                @copy_config( temp, locals[file_name] )

    browser_sync: (config) ->
        browserSync(
            proxy: "localhost:#{config.dev_port}" # sets up what the proxy should be
            port: config.dev_port+1 # set up port to watch/proxy
            ui:
                port: config.dev_port+2 # where the UI can be accessed
                weinre: 9090
            watchOptions:
                debounceDelay: 1000
            ghostMode:
                clicks: true
                forms: true
                scroll: true
            logPrefix: "#{config.url} -- DEV" # give it a name
            open: if config.debug then true else config.ui # do we open a browser, or the ui?
            browser: if config.debug then ["google chrome", "firefox", "opera", "safari"] else false
            startPath: config.view # where should the browser open up to?
            xip: false
            reloadOnRestart: true
            notify: true
            injectChanges: true
        )

    bs_notify: (type) ->
        browserSync.notify( "<span style='color:goldenrod'>Running:</span> [#{type}]" )

    # uses charge
    serve: (config) ->
        app = charge( config.local_server.build,
                config.local_server.options
            )

        http.createServer(app).listen(config.dev_port)

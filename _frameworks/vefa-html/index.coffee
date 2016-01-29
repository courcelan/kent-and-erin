compiler = require 'jade'
md = require 'kramed'
# helpers = require '../tasks/helpers.coffee'

compiler_opts = {}

render = (block) ->
    return compiler.render( block, compiler_opts )

django_expression = (obj) ->
    return [Object.keys(obj).join(" "), Object.keys(obj)[0]]

single_var = (name) ->
    """{{ #{ name } }}\r"""

get_expression = (opts) ->
    if opts
        delete opts.filename
        return Object.keys(opts).join(" ")
    else
        return null

get_values = (opts) ->
    if opts
        delete opts.filename
        return Object.keys(opts)
    else
        return null

get_quoted_expression = (opts) ->
    return q( get_expression( opts ) )

q = (val) ->
    return "\"#{ val }\""

q_fence = (expression) ->
    return expression.replace(/\*/gi, "\"")

operator_replace = (expression) ->
    expression = expression.replace(/ gte /gi, " >= ")
    expression = expression.replace(/ gt /gi, " > ")
    expression = expression.replace(/ lte /gi, " <= ")
    expression = expression.replace(/ lt /gi, " < ")
    expression = expression.replace(/ is not /gi, " != ")
    expression = expression.replace(/ is /gi, " == ")
    expression = expression.replace(/ eq /gi, " = ")
    return expression


single_tag = (name, expression="") ->
    if expression
        template = """{% #{ name } #{ expression } %}\r"""
    else
        template = """{% #{ name } %}\r"""

    # if not options.build_config.shopify
    #     template = ""

    return template


block_tag = (tag_name, expression, insertion) ->
    if insertion
        template =
            """
            \r{% #{ tag_name } #{ expression } %}#{ insertion }
            {% end#{ tag_name } %}\r
            """
    else
        template ="""\r{% #{ tag_name } #{ expression } %}{% end#{ tag_name } %}\r"""

    # if not options.build_config.shopify
    #     template = insertion

    return template



# ==================================================================================================
# DJANGO TEMPLATES
#
#
django_templates = ->

    _: (block, opts) ->
        if opts
            delete opts.filename
            expression = django_expression(opts)[0]
            template =
                """
                {% #{ expression } %}
                \n
                """

            return template

    # used to build django tags that wrap and do not need escaping (or put in "")
    __: (block, opts) ->
        delete opts.filename
        console.log opts
        console.log Object.keys(opts)
        console.log Object.keys(opts)[0]
        console.log Object.keys(opts)[1]
        console.log get_expression(opts)
        # if opts
        #     delete opts.filename
        #     expression = django_expression( opts )[0]
        #     tagname = django_expression( opts )[1]
        #     insertion = render(block)
        #     template =
        #         """
        #         {% #{ expression } %}
        #         #{ insertion }
        #         {% end#{ tagname } %}
        #         \n
        #         """
        return ""

    for: (block, opts) ->
        block_tag("for", get_expression(opts), render(block))

    if: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        block_tag( "if", expression, render(block) )

    else: (block) ->
        single_tag("else") + render(block)

    with: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        block_tag( "with", expression, render(block) )

    extends: (block, opts) ->
        single_tag( "extends", q("#{ get_expression(opts) }.html") )

    include: (block, opts) ->
        single_tag( "include", q("#{ get_expression(opts) }.html") )

    load: (block, opts) ->
        single_tag( "load", get_expression(opts) )

    block: ( block, opts ) ->
        block_tag( "block", get_expression(opts), render(block) )

    static: (block, opts) ->
        expression = get_expression(opts)
        if expression.indexOf(" as ") != -1
            expression_arr = expression.split(" ")
            expression_arr[0] = q( expression_arr[0] )
            expression = expression_arr.join(" ")
        single_tag("static", expression)

    csrf_token: (block) ->
        single_tag("csrf_token")

    var: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        single_var( expression )



# ==================================================================================================
# DJANGO CMS
#
#
django_cms = ->

    cms_toolbar: (block) ->
        single_tag("cms_toolbar")

    if_edit: (block) ->
        insertion = render(block)
        block_tag("if", "request.toolbar.edit_mode", insertion)

    if_live: (block, opts) ->
        live_obj = q( get_expression(opts) )
        insertion = render(block)

        if live_obj
            expression = "#{ live_obj } and not request.toolbar.edit_mode"
        else
            expression = "not request.toolbar.edit_mode"

        block_tag("if", expression, insertion)

    only_live: (block, opts) ->
        expression = "not request.toolbar.edit_mode"
        block_tag("if", expression, render(block))

    render: (block, opts) ->
        single_tag( "render_block", get_quoted_expression(opts) )

    render_plugin: (block, opts) ->
        single_tag( "render_plugin", get_expression(opts) )

    add_to: (block, opts) ->
        block_tag( "addtoblock", get_quoted_expression(opts), render(block) )

    add_to_css: (block) ->
        block_tag("addtoblock", q("css"), render(block))

    add_to_js: (block) ->
        block_tag("addtoblock", q("js"), render(block))

    placeholder: (block, opts) ->
        placeholder_name = q( get_expression(opts) )
        single_tag("placeholder", placeholder_name )

    static_placeholder: (block, opts) ->
        placeholder_name = q( get_expression(opts) )
        single_tag("static_placeholder", placeholder_name )

    show_placeholder: (block, opts) ->
        expression = q( get_expression(opts) )
        single_tag("show_placeholder", expression )

    show_menu_below_id: (block, opts) ->
        if opts
            values = get_values(opts)
            expression = "#{ q(values[0]) } 0 100 0 0 #{ q( values[1] ) } "
            single_tag("show_menu_below_id", expression)

    show_sub_menu: (block, opts) ->
        if opts
            expression = q( get_expression(opts) )
            expression = "2 2 0 100 #{ expression } "
            single_tag("show_menu", expression)

    show_editable_titles: (block, opts) ->
        if opts
            expression = q( get_expression(opts) )
            expression = "request.current_page 'title' '#{ expression }'"
            single_tag("render_model", expression)

    show_editable_page_title: (block) ->
        expression = "request.current_page 'title' 'title, page_title'"
        single_tag("render_model", expression)


# ==================================================================================================
# LIQUID/SHOPIFY
#
#
shopify = ->
    shopify: ( block ) ->
        if options.build_config.shopify
            return render( block )
        else
            return ""

    snippet: (block, opts) ->
        single_tag( "include", q("#{ get_expression(opts) }") )

    unless: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        block_tag( "unless", expression, render(block) )

    case: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        block_tag( "case", expression, render(block) )

    when: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        single_tag( "when", expression )

    assign: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        single_tag( "assign", expression )

    capture: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        expression = q_fence(expression)
        block_tag( "capture", expression, render(block) )

    form: (block, opts) ->
        expression = get_expression(opts)
        expression = operator_replace(expression)
        block_tag( "form", q(expression), render(block) )

# ==================================================================================================
# EXPORTS
#
#
module.exports = (options) ->
    vefa =
        functions:
            static: (file) ->
                assets_dir = options.build_config.assets.destination.split("/")
                assets_dir.shift()
                assets_dir = assets_dir.join("/")
                return "/#{assets_dir}/#{file}"

            ie_basics: () ->
                template =
                    """
                        \r<!--[if IE]>
                        <meta http-equiv="imagetoolbar" content="no" />
                        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
                        <![endif]-->\r
                    """
                return template


            viewport: () ->
                template = render(
                    """
                    meta(
                        name="viewport"
                        content="width=device-width, initial-scale=1.0"
                    )
                    """
                )

                return template


            canonical: (href) ->
                if href
                    template = render(
                        """
                        link(rel="canonical", href="#{ href }")
                        """
                    )

                    return template

            meta_description: (desc) ->
                if desc
                    template = render(
                        """
                         meta(name="description", content="#{ desc }")
                        """
                    )

                    return template


            site_author: (name, humans_text) ->
                author =
                    """
                    meta(name="author", content="#{ name }")
                    """
                text_link = ""
                if humans_text
                    text_link =
                        """
                        link(
                            rel="author"
                            href="#{ humans_text }"
                        )
                        """
                template = render(
                    """
                        #{ author }
                        #{ text_link }
                    """
                )

                return template


            google_verification: (id) ->
                template = render(
                    """
                    meta(
                        name="google-site-verification"
                        content="#{ id }"
                    )
                    """
                )

                return template


            ng_template: (opts) ->
                if opts.name? and !opts.template
                    opts.template = opts.name

                if opts.template? and !opts.name
                    opts.name = opts.template

                template = render(
                    """
                    script(type="text/ng-template" id="#{ opts.name }.html").
                        {{ include "angular/#{ opts.template }.html" }}
                    """
                )
                return template

            shopify: () ->
                if options.build_config.shopify
                    return arguments[0]
                else
                    return arguments[1]

        filters:
            jade: ( block, opts ) ->
                if not options.build_config.shopify
                    return render( block )
                else
                    return ""

            markdown: ( block ) ->
                md.setOptions(
                    renderer: new md.Renderer()
                    gfm: true
                    tables: true
                    breaks: false
                    pedantic: false
                    sanitize: false
                    smartLists: true
                    smartypants: true
                )
                return md( block )
    if options.build_config.jade.framework.includes?
        for item in options.build_config.jade.framework.includes
            for key, value of eval(item)()
                vefa.filters[key] = value

    compiler_opts = options
    compiler_opts.basedir = "./#{ options.build_config.source }/#{ options.build_config.jade.cwd }"
    compiler_opts.pretty = true
    compiler_opts.compileDebug = false
    compiler_opts.doctype = 'html'
    compiler_opts.vefa = vefa.functions
    compiler_opts.filters = vefa.filters

    return vefa

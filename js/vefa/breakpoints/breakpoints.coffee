angular.module('Vefa.breakpoints', [])

.service 'responsiveLayoutService',
[
    '$window'
    '$timeout'
    '$rootScope'
    ($window, $timeout, $root) ->
        watch: null
        checkMedia: (breakpoints) ->
            if window.matchMedia(breakpoints).matches
                return true
            return false

        addSubscriber: (obj) ->
            @subscribers.push obj

        resizeEvent: ->
            $root.$broadcast("responsive:resize")

        setWatch: ->
            @watch = true
            resizeEvent = =>
                @resizeEvent()

            angular.element($window).on 'resize',
                ->
                    $timeout.cancel(resizeEvent)
                    $timeout(
                        resizeEvent
                        1000
                    )
                    return

            return

        adaptUi: (breakpoints, parent, transfer_list) ->
            switchUi = () =>
                if @checkMedia(breakpoints)
                    switch type
                        when "append" then parent.append children
                        when "prepend" then parent.prepend children

            control_list = transfer_list.split(":")
            type = control_list[0]
            children = angular.element(document.querySelector(control_list[1]))

            console.log children

            switchUi()

            if @watch
                $root.$on(
                    "responsive:resize"
                    (e) ->
                        switchUi()
                )

        resizeUi: (breakpoints, element, attr) ->
            toggleClass = =>
                if @checkMedia(breakpoints)
                    element.addClass attr
                else
                    element.removeClass attr

            toggleClass()

            if @watch
                $root.$on(
                    "responsive:resize"
                    (e) ->
                        toggleClass()
                )


        styleUi: (breakpoints, element, attr) ->
            styleElement = () =>
                element.removeAttr( "style" )
                element.attr( "style", attr ) if @checkMedia(breakpoints)

            styleElement()

            if @watch
                $root.$on(
                    "responsive:resize"
                    (e) ->
                        styleElement()
                )

        bkgUi: (breakpoints, element, attr) ->
            styleElement = () =>
                element.css( { backgroundImage: "" } )
                element.css( { backgroundImage: "url(#{attr})" } ) if @checkMedia( breakpoints )

            styleElement()

            if @watch
                $root.$on(
                    "responsive:resize"
                    (e) ->
                        styleElement()
                )

        minWidth: (value) ->
            return "(min-width: #{value})"

        maxWidth: (value) ->
            return "(max-width: #{value})"

        betweenWidths: (values) ->
            try
                values.length == 2
            catch error
                console.log error

            return "(min-width:#{ values[0] }) and (max-width:#{ values[1] })"
]


.directive 'cndUi',
[
    'responsiveLayoutService',
    'BREAKPOINTS'
    ($service, BREAKPOINTS) ->
        scope: true
        link: (_, element, attr) ->
            $service.resizeUi(
                $service.maxWidth(BREAKPOINTS.condensed)
                element
                attr.cndUi
            )
]


.directive 'enhUi',
[
    'responsiveLayoutService'
     'BREAKPOINTS'
    ($service, BREAKPOINTS) ->
        scope: true
        link: (_, element, attr) ->
            $service.resizeUi(
                $service.betweenWidths([BREAKPOINTS.condensed, BREAKPOINTS.extended])
                element
                attr.enhUi
            )
]


.directive 'extUi',
[
    'responsiveLayoutService'
     'BREAKPOINTS'
    ($service, BREAKPOINTS) ->
        scope: true
        link: (_, element, attr) ->
            $service.resizeUi(
                $service.minWidth(BREAKPOINTS.extended)
                element
                attr.extUi
            )
]


.directive 'overCndUi',
[
    'responsiveLayoutService'
     'BREAKPOINTS'
    ($service, BREAKPOINTS) ->
        scope: true
        link: (_, element, attr) ->
            $service.resizeUi(
                $service.minWidth(BREAKPOINTS.condensed)
                element
                attr.overCndUi
            )
]


.directive 'underExtUi',
[
    'responsiveLayoutService'
     'BREAKPOINTS'
    ($service, BREAKPOINTS) ->
        scope: true
        link: (_, element, attr) ->
            $service.resizeUi(
                $service.maxWidth(BREAKPOINTS.extended)
                element
                attr.underExtUi
            )
]

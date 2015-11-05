angular.module('Vefa.navigation', [])

.directive 'urlActivate', ->
    restrict: 'AC'
    scope: true
    bindToController: true
    controller: [
        '$element'
        ($element) ->
            href = $element.attr('href')
            path = window.location.pathname

            # test to see if url matches the current url of the page
            if path == href || path == href.slice(0, href.length-1)
                $element.addClass('is-active')
    ]

.directive 'absoluteUrlActivate', ->
    restrict: 'AC'
    scope: true
    bindToController: true
    controller: [
        '$element'
        ($element) ->
            href = $element.attr('href')
            href = href.slice(0, href.length-1)
            path = window.location.pathname

            # test to see if url contains the url of the active link
            if path.indexOf(href) is 0
                $element.addClass('is-active')
    ]

angular.module('Vefa.avi', [])

.directive 'youtubeEmbed', ->
    scope:
        youtubeEmbed: '@'
        embedId: '@'
    link: (scope, element, attrs) ->
        element.bind 'click', ($event) ->
            do $event.preventDefault

            # doesn't work on staging as we arent tracking
            # if _gaq?
            #     _gaq.push(
            #         [
            #             '_trackEvent'
            #             'video'
            #             'play'
            #             "youtu.be/#{ scope.youtubeEmbed }"
            #         ]
            #     )

            scope.videoEmbed = true

            filters = "?autoplay=1&rel=0"

            loadingArea = document.getElementById(scope.embedId)

            loadingArea.classList.toggle("has-active-content")

            loadingArea.innerHTML =
                """
                <iframe
                    src="//www.youtube.com/embed/#{scope.youtubeEmbed}#{filters}"
                    scrolling="no"
                    frameborder="0"
                    allowfullscreen=""
                    class="embed-item"
                ></iframe>
                """

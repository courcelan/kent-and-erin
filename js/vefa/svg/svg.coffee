angular.module('Vefa.svg', [])

.directive 'svgLoader', [
    '$http'
    ( $http ) ->
        scope:
            file: '@svgLoader'
            revision: '@svgRevision'
        link: ($scope, $element) ->
            svgRect = document.createElementNS( 'http://www.w3.org/2000/svg', 'svg' ).createSVGRect

            if not document.createElementNS or not svgRect
                return true

            @isLocalStorage =( localStorage? and window[ 'localStorage' ] isnt null )

            @insert_svg = ( svg ) ->
                $element.prepend( svg )

            @insert = ( svg ) ->
                if document.body
                    @insert_svg( svg )
                else
                    document.addEventListener( 'DOMContentLoaded', @insert_svg( svg ) )


            if @isLocalStorage && localStorage.getItem( 'SVGRev' ) == $scope.revision
                data = localStorage.getItem( 'SVGData' )

                if data
                    @insert_svg( data )

            else
                $http
                    .get( $scope.file )
                    .success( ( svg ) =>
                        @insert( svg )

                        if @isLocalStorage
                            localStorage.setItem("SVGData", svg)
                            localStorage.setItem("SVGRev", $scope.revision)
                            @isLocalStorage = false
                    )

]

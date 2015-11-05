angular.module('client',
    [
        'Vefa.breakpoints'
        'Vefa.navigation'
        'Vefa.svg'
        'Vefa.avi'
    ]
)

.constant 'BREAKPOINTS',
    floor: '320px'
    condensed: '600px'
    standard: '768px'
    # enhanced uses condensed and extended
    extended: '900px'
    expanded: '1200px'

.config [
    '$compileProvider'
    ($compileProvider) ->
        $compileProvider.debugInfoEnabled(false)
]

.run [
    'responsiveLayoutService',
    ($responsive) ->
        $responsive.setWatch()
]

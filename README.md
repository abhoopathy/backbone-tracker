backbone-tracker
=====

Mixes declarative mixpanel tracking into
Backbone.View

If events hash is:

    events:
        'click a' : 'click link'

Track it with a string

    track:
        'click' : 'Clicked Link'

An object

    track:
          'click' :
              name: 'Clicked Link'
              data: {linkName: 'I Like Turtles'}

A function

      track:
          'click' :
              name: 'Clicked Link'
              data: (event) -> {
                  linkHref: event.target.attr('href')
                  time: new Date()
              }

(note, function's `this` is the view, not event
target element)

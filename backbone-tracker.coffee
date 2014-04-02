
#### Mixes declarative mixpanel tracking into
#### Backbone.View
####
####    If events hash is:
####
####        events:
####            'click a' : 'click link'
####
####    ---- Track it with a string ----
####
####       track:
####           'click' : 'Clicked Link'
####
####    ---- An object ----
####
####        track:
####            'click' :
####                name: 'Clicked Link'
####                data: {linkName: 'I Like Turtles'}
####
####    ---- A function ----
####
####        track:
####            'click' :
####                name: 'Clicked Link'
####                data: (event) -> {
####                    linkHref: event.target.attr('href')
####                    time: new Date()
####                }
####
####    (note, function's `this` is the view, not event
####    target element)


BackboneTracker = ((Backbone, config) ->

    throw 'No config parameter' unless config?
    throw 'Config needs trackEvent function' unless config.trackEvent?

    oldDelegateEvents = Backbone.View.prototype.delegateEvents
    delegateEventSplitter = /^(\S+)\s*(.*)$/

    toReturn = _.extend Backbone.View.prototype,


        delegateEvents: (events) ->
            if (!(events || (events = _.result(this, 'events'))))
                return this

            @undelegateEvents()

            _.each events, (val, key) =>
                method = events[key]
                if (!_.isFunction(method))
                    method = this[events[key]]
                if (!method) then return

                match = key.match(delegateEventSplitter)
                eventName = match[1]
                selector = match[2]
                method = _.bind(method, this)
                eventName += '.delegateEvents' + @cid

                if (selector == '')
                    if @track? and _.has(@track, key)
                        @$el.on eventName, (e) =>
                            result = method.apply(this, arguments)
                            _trackOnViewEvent.call(this, key, e)
                            return result
                    else
                        @$el.on(eventName, method)
                else
                    if @track? and _.has(@track, key)
                        @$el.on eventName, selector, (e) =>
                            result = method.apply(this, arguments)
                            _trackOnViewEvent.call(this, key, e)
                            return result
                    else
                        @$el.on(eventName, selector, method)

            @bindKeyboardEvents() if @bindKeyboardEvents?

            return this


        ## Public wrapper for helper, attached to
        ## Backbone.View. Required an eventName. Optionally
        ## takes eventData
        trackEvent: (eventName, eventData) ->
            _sendTrackEvent(eventName, eventData)




    #### Helpers ####

    ## When a view's event is triggered, and there is a
    ## corresponding entry in track, 'track' the event with
    ## the given configuration. Value can be a string,
    ## or an object with name and data property. Data can be
    ## an object, or function returning an object.
    _trackOnViewEvent = (key, e) ->

        # make sure defined
        val = @track[key]

        if _.isString(val)
            _sendTrackEvent(@track[key])

        else if _.isObject(val)
            return if !(val.name? and val.data?)
            if _.isFunction(val.data)
                _sendTrackEvent(val.name, val.data.call(this,e))
            else if _.isObject(val.data)
                _sendTrackEvent(val.name, val.data)


    ## Broadcast the track event through chrome message
    ## passing, where background-script publishes it to
    ## mixpanel. Requires an event `name`. Optionally takes an
    ## event `data` object or a function that makes one.
    _sendTrackEvent = (eventName, eventData={}) ->
        config.trackEvent(eventName, eventData)

)

if ( typeof define == "function" && define.amd )
    define "backbone-tracker", [],  -> BackboneTracker

if module?.exports?
    module.exports = BackboneTracker

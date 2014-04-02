backbone-tracker
=====

### backbone-tracker mixes declarative user event tracking into Backbone.View. AMD & CommonJS friendly. I think.

```
bower install backbone-tracker
```

First, specify a callback for tracking events app-wide. Specify how actions hook up to your analytics API (e.g. Mixpanel or Google analytics)

```javascript
BackboneTracker(Backbone, {

    trackEvent: function(eventName, eventData) {

        // Track with mixpanel
        mixpanel.track(eventName, eventData);

        // or KISSmetrics:
        // _kmq.push(['record', eventName])

        // or Google Analytics:
        // _gaq.push(['_trackEvent', 'Home', eventName]);

    }
})
```



Now, you can give your views a track object to parallel the events object:


```javascript
var MainView = new Backbone.View.extend({
    
    events: {
        'dblclick a'    : 'onLinkDblClick'
        'click .submit' : 'onSubmitClick'
    }
    
    /* These events will be logged */
    track: {
        'dblclick a'    : 'Double Click on Link'
        'click .submit' : 'Submit Form'
    }	
    
    onLinkDblClick: function(event) {...}
    onSubmitClick: function(event) {...}


});
```


Track with a string:

```coffeescript
track:
    'click a' : 'Clicked Link'
```


Track with an object, if you have payload.:

```coffeescript
track:
    'click a':
        name: 'Clicked Link'
        data: { user: USER_ID }
```
          

Or a function can generate the payload when the event happens:

```coffeescript
track:
    'click a' :
        name: 'Clicked Link'
        data: (event) ->
            {
                linkHref: event.target.attr('href'),
                time: new Date()
            }
```


(Note, this functions context is the view, not event
target element.)

This also attaches a method `trackEvent` to the view, for more complicated cases.


```javascript
var MainView = new Backbone.View.extend({
    ...	
    onLinkDblClick: function(event) {
        this.trackEvent('Link Double Clicked', {
            user_id: this.model.get('id')
        })
    }
    ...

});
```

MIT LICENSE

Inspired by [backbone.mousetrap](https://github.com/elasticsales/backbone.mousetrap).

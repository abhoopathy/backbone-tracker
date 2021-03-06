(function() {
  var BackboneTracker;

  BackboneTracker = (function(Backbone, config) {
    var delegateEventSplitter, oldDelegateEvents, toReturn, _sendTrackEvent, _trackOnViewEvent;
    if (config == null) {
      throw 'No config parameter';
    }
    if (config.trackEvent == null) {
      throw 'Config needs trackEvent function';
    }
    oldDelegateEvents = Backbone.View.prototype.delegateEvents;
    delegateEventSplitter = /^(\S+)\s*(.*)$/;
    toReturn = _.extend(Backbone.View.prototype, {
      delegateEvents: function(events) {
        if (!(events || (events = _.result(this, 'events')))) {
          return this;
        }
        this.undelegateEvents();
        _.each(events, (function(_this) {
          return function(val, key) {
            var eventName, match, method, selector;
            method = events[key];
            if (!_.isFunction(method)) {
              method = _this[events[key]];
            }
            if (!method) {
              return;
            }
            match = key.match(delegateEventSplitter);
            eventName = match[1];
            selector = match[2];
            method = _.bind(method, _this);
            eventName += '.delegateEvents' + _this.cid;
            if (selector === '') {
              if ((_this.track != null) && _.has(_this.track, key)) {
                return _this.$el.on(eventName, function(e) {
                  var result;
                  result = method.apply(_this, arguments);
                  _trackOnViewEvent.call(_this, key, e);
                  return result;
                });
              } else {
                return _this.$el.on(eventName, method);
              }
            } else {
              if ((_this.track != null) && _.has(_this.track, key)) {
                return _this.$el.on(eventName, selector, function(e) {
                  var result;
                  result = method.apply(_this, arguments);
                  _trackOnViewEvent.call(_this, key, e);
                  return result;
                });
              } else {
                return _this.$el.on(eventName, selector, method);
              }
            }
          };
        })(this));
        if (this.bindKeyboardEvents != null) {
          this.bindKeyboardEvents();
        }
        return this;
      },
      trackEvent: function(eventName, eventData) {
        return _sendTrackEvent(eventName, eventData);
      }
    });
    _trackOnViewEvent = function(key, e) {
      var val;
      val = this.track[key];
      if (_.isString(val)) {
        return _sendTrackEvent(this.track[key]);
      } else if (_.isObject(val)) {
        if (!((val.name != null) && (val.data != null))) {
          return;
        }
        if (_.isFunction(val.data)) {
          return _sendTrackEvent(val.name, val.data.call(this, e));
        } else if (_.isObject(val.data)) {
          return _sendTrackEvent(val.name, val.data);
        }
      }
    };
    return _sendTrackEvent = function(eventName, eventData) {
      if (eventData == null) {
        eventData = {};
      }
      return config.trackEvent(eventName, eventData);
    };
  });

  if (typeof define === "function" && define.amd) {
    define("backbone-tracker", [], function() {
      return BackboneTracker;
    });
  }

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = BackboneTracker;
  }

}).call(this);

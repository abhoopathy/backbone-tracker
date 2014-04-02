jsdom  = require('jsdom')
chai   = require("chai")
sinon  = require("sinon")
BackboneTracker = require('../backbone-tracker.coffee')

expect = chai.expect
assert = chai.assert

describe 'Backbone Tracker', ->

    beforeEach((done) ->
        jsdom.env
            html: "<html><body></body></html>"
            done: (errs, window) ->
                global.window = window
                global._ = require('underscore')
                global.$ = require('jquery')
                global.App = {};
                done()
    )

    describe 'constructor', ->

        beforeEach ->
            Backbone = require('backbone')
            Backbone.$ = $

        it 'should need config param', ->
            expect(-> BackboneTracker(Backbone))
                .to.throw()

        it 'should need config.trackEvent', ->
            expect(-> BackboneTracker(Backbone, {})
            ).to.throw()


    describe 'view instance', ->

        trackFn = null

        beforeEach ->
            Backbone = require('backbone')
            Backbone.$ = $
            BackboneTracker Backbone, {
                trackEvent: trackFn = sinon.spy()
            }
            App.View = Backbone.View.extend()

        it 'should have trackEvent function', ->
            view = new App.View()
            expect(view).to.respondTo('trackEvent')
            view.trackEvent('Click')
            expect(trackFn.called).to.be.true

    describe 'view.track object entry', ->

        trackFn = null
        $el = null

        beforeEach ->
            global.Backbone = require('backbone')
            Backbone.$ = $
            BackboneTracker Backbone, {
                trackEvent: trackFn = sinon.spy()
            }
            $el = $(
                """
                <div class='container'>
                    <a href='/home'>home</a>
                </div>
                """
            )

        it 'can be a string', ->
            App.View = Backbone.View.extend(
                events:
                    'click a': evtHandler=sinon.spy()
                track:
                    'click a': 'Clicked Link'
            )
            view = new App.View {el: $el}
            view.$('a').click()
            expect(trackFn.calledWith('Clicked Link')).to.be.true
            console.log trackFn.callCount

        it 'can be an object', ->
            App.View = Backbone.View.extend(
                events:
                    'click a': evtHandler=sinon.spy()
                track:
                    'click a': {
                        name: 'Clicked Link'
                        data: {
                            linkName: 'home'
                            user: '1'
                        }
                    }
            )
            view = new App.View(el: $el)
            view.$('a').click()
            expect(evtHandler.called).to.be.true
            expect(trackFn.calledWith(
                'Clicked Link',
                { linkName: 'home', user: '1' }
            )).to.be.true

        it 'can be a function', ->
            App.View = Backbone.View.extend(
                events:
                    'click a': evtHandler=sinon.spy()
                track:
                    'click a': {
                        name: 'Clicked Link'
                        data: (e)->
                            {
                                linkName: 'home'
                                href: $(e.target).attr('href')
                            }
                    }
            )
            view = new App.View(el: $el)
            view.$('a').click()
            expect(evtHandler.called).to.be.true
            expect(trackFn.calledWith(
                'Clicked Link',
                { linkName: 'home', href: '/home' }
            )).to.be.true

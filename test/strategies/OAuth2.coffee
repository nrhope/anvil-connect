# Test dependencies
nock      = require 'nock'
chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect
FormUrlencoded = require('form-urlencoded')




# Assertions
chai.use sinonChai
chai.should()




# Code under test
Strategy = require('passport-strategy')
OAuth2Strategy = require '../../lib/strategies/OAuth2'



describe 'OAuth2 Strategy', ->


  {err, res, credentials} = {}

  provider =
    id:           'id'
    name:         'Name'
    protocol:     'OAuth 2.0'
    url:          'https://domain.tld'
    redirect_uri: 'https://local.tld/callback'
    scope:        ['a', 'b']
    separator: ' '
    endpoints:
      authorize:
        url:      'https://domain.tld/authorize'
        method:   'POST'
      token:
        url:      'https://domain.tld/token'
        method:   'POST'
        auth:     'client_secret_basic'
      user:
        url:      'https://domain.tld/userinfo'
        method:   'GET'
        auth:     'bearer_token'
    mapping:
      name: 'name'

  config =
    client_id:      'id',
    client_secret:  'secret'
    scope:          ['c']

  verify = (req, res, profile) ->

  strategy = new OAuth2Strategy provider, config, verify


  describe 'instance', ->

    it 'should inherit from Strategy', ->
      expect(strategy).to.be.instanceof Strategy


  describe 'constructor', ->

    it 'should set provider', ->
      strategy.provider.should.equal provider

    it 'should set endpoints', ->
      strategy.endpoints.should.equal provider.endpoints

    it 'should set client', ->
      strategy.client.should.equal config

    it 'should set name', ->
      strategy.name.should.equal provider.id

    it 'should set verify', ->
      strategy.verify.should.equal verify



  describe 'authenticate', ->

    describe 'with new authorization request', ->

      req = query: { query: {} }
      options = state: 'st4t3'

      before ->
        sinon.stub(strategy, 'authorizationRequest')
        strategy.authenticate req, options

      after ->
        strategy.authorizationRequest.restore()

      it 'should initialize the authorization flow', ->
        strategy.authorizationRequest.should.have.been.calledWith req, options


    describe 'with authorization error response', ->

    describe 'with authorization code response', ->




  describe 'base64credentials', ->

    before ->
      credentials = strategy.base64credentials()

    it 'should include the client_id', ->
      new Buffer(credentials, 'base64')
        .toString().should.contain config.client_id

    it 'should include the client_secret', ->
      new Buffer(credentials, 'base64')
        .toString().should.contain config.client_secret

    it 'should include the separator', ->
      new Buffer(credentials, 'base64')
        .toString().should.contain ':'




  describe 'authorizationRequest', ->

    describe 'with valid configuration', ->

      req = query: { query: {} }
      options = state: 'st4t3'

      beforeEach ->
        strategy.redirect = sinon.spy()
        strategy.authorizationRequest(req, options)

      it 'should redirect', ->
        url = provider.endpoints.authorize.url
        strategy.redirect.should.have.been.calledWith sinon.match(url)

      it 'should include response_type', ->
        strategy.redirect.should.have.been.calledWith sinon.match(
          'response_type=code'
        )

      it 'should include client_id', ->
        strategy.redirect.should.have.been.calledWith sinon.match(
          'client_id=' + config.client_id
        )
      it 'should include redirect_uri', ->
        strategy.redirect.should.have.been.calledWith sinon.match(
          'redirect_uri=' + encodeURIComponent(provider.redirect_uri)
        )

      it 'should include scope', ->
        strategy.redirect.should.have.been.calledWith sinon.match(
          'scope=a%20b%20c'
        )

      it 'should include state', ->
        strategy.redirect.should.have.been.calledWith sinon.match(
          'state=' + options.state
        )




  describe 'userInfo', ->

    describe 'with bearer token', ->

      before (done) ->
        scope = nock(provider.url)
                .matchHeader('Authorization', 'Bearer token')
                .matchHeader('User-Agent', 'Anvil Connect/0.1.26')
                .get('/userinfo')
                .reply(200, { _id: 'uuid', name: 'Jane Doe' })
        strategy.userInfo 'token', (error, response) ->
          err = error
          res = response
          done()


      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the user info', ->
        res.name.should.equal 'Jane Doe'
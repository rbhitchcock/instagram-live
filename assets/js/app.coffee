initSession = ->
  if not sessionStorage.getItem("subscriptions")
    sessionStorage.setItem("subscriptions", JSON.stringify([]))
 
{div, ul, li, div, h3, form, input, button} = React.DOM

SubscriptionList = React.createClass
  render: ->
    createItem = (subName) ->
      (Subscription {name: subName})
    (ul {className: "subscription-list"}, [@props.subscriptions.map createItem])

Subscription = React.createClass
  render: ->
    (li {className: "subscription"}, [@props.name])

StreamerApp = React.createClass
  getInitialState: ->
    subscriptions: []
    text: ''

  onChange: (e) ->
    @setState text: e.target.value

  handleSubmit: (e) ->
    e.preventDefault();
    nextItems = @state.subscriptions.concat [@state.text]
    nextText = ''
    @setState subscriptions: nextItems, text: nextText

  render: ->
    (div {}, [
      (h3 {}, ['TODO']),
      (SubscriptionList {subscriptions: @state.subscriptions})
      (form {onSubmit: @handleSubmit}, [
        (input {onChange: @onChange, value: @state.text}),
        (button {}, ['Add #' + (@state.subscriptions.length + 1)])
      ])
    ])

initSession()
React.renderComponent (StreamerApp {}), $('div.app')[0]

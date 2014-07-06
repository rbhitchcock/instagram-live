initApp = ->
  if not sessionStorage.getItem("subscriptions")
    sessionStorage.setItem("subscriptions", JSON.stringify([]))

  $('a.toggle-fullscreen').click(toggleFullScreen)
  $('a.simulate').click(simulatePost)
  $('.stream').slick({
    infinite: false,
    slidesToShow: 3,
    slidesToScroll: 1,
    arrows: false
  })

  il = new EventSource('/subscribe')
  il.onmessage = (e) ->
    console.log(e.data)

simulatePost = (e) ->
  e.preventDefault()
  $.post('/iglistener', {msg: "HIDEY"})

toggleFullScreen = (e) ->
  e.preventDefault()

  if !document.fullscreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement
    if document.documentElement.requestFullscreen
      document.documentElement.requestFullscreen()
    else if document.documentElement.msRequestFullscreen
      document.documentElement.msRequestFullscreen()
    else if document.documentElement.mozRequestFullScreen
      document.documentElement.mozRequestFullScreen()
    else if document.documentElement.webkitRequestFullscreen
      document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT)
  else
    if document.exitFullscreen
      document.exitFullscreen()
    else if document.msExitFullscreen
      document.msExitFullscreen()
    else if document.mozCancelFullScreen
      document.mozCancelFullScreen()
    else if document.webkitExitFullscreen
      document.webkitExitFullscreen()

 
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

initApp()
#React.renderComponent (StreamerApp {}), $('div.app')[0]

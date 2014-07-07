initApp = ->
  if not sessionStorage.getItem("subscriptions")
    sessionStorage.setItem("subscriptions", JSON.stringify([]))

  $('a.toggle-fullscreen').click(toggleFullScreen)
  $('a.simulate').click(simulatePost)
  $('.stream').slick({
    infinite: false,
    slidesToShow: 3,
    slidesToScroll: 1,
    arrows: true
  })

  il = new EventSource('/subscribe')
  il.onerror = (e) ->
    console.log("error")

  num_images = 0
  il.onmessage = (e) ->
    images = JSON.parse(e.data)
    $.each(images, (_, image) ->
      num_images++
      url = image.images.standard_resolution.url
      $('.stream').slickAdd('<div class="image"><img src="'+url+'"/></div>')
    )
    console.log(num_images)
    $('.stream').slickGoTo(num_images - 3)

  timer = null
  $(window).on('mousemove', Foundation.utils.throttle(() ->
    $('nav').slideDown()
    try
      clearTimeout(timer)
    catch e
      console.log('error')
    timer = setTimeout(() ->
      $('nav').slideUp()
    , 1000)
  300))

simulatePost = (e) ->
  e.preventDefault()
  $.post('/uh', {msg: "HIDEY"})

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

 
{img, div, ul, li, div, h3, form, input, button} = React.DOM

Image = React.createClass
  render: ->
    1

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

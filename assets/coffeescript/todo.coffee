{ul, li, div, h3, form, input, button} = React.DOM

TodoList = React.createClass
  render: ->
    createItem = (itemText) ->
      (li {}, [itemText])
    (ul {}, [@props.items.map createItem]);

TodoApp = React.createClass
  getInitialState: ->
    items: []
    text: ''

  onChange: (e) ->
    @setState text: e.target.value

  handleSubmit: (e) ->
    e.preventDefault();
    nextItems = @state.items.concat [@state.text]
    nextText = ''
    @setState items: nextItems, text: nextText

  render: ->
    (div {}, [
      (h3 {}, ['TODO']),
      (TodoList {items: @state.items})
      (form {onSubmit: @handleSubmit}, [
        (input {onChange: @onChange, value: @state.text}),
        (button {}, ['Add #' + (@state.items.length + 1)])
      ])
    ])

React.renderComponent (TodoApp {}), document.body

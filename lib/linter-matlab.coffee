LinterMatlabView = require './linter-matlab-view'
{CompositeDisposable} = require 'atom'

module.exports = LinterMatlab =
  linterMatlabView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @linterMatlabView = new LinterMatlabView(state.linterMatlabViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @linterMatlabView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'linter-matlab:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @linterMatlabView.destroy()

  serialize: ->
    linterMatlabViewState: @linterMatlabView.serialize()

  toggle: ->
    console.log 'LinterMatlab was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

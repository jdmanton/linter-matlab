{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'

module.exports =
	config:
		mlintDir:
			default: ""
			type: 'string'
			title: 'Path to directory containing mlint'

	activate: (state) ->
		console.log 'linter-matlab loaded.'
		@subscriptions = new CompositeDisposable
		@subscriptions.add atom.config.observe 'linter-matlab.mlintDir',
			(mlintDir) =>
				@mlintDir = mlintDir

	deactivate: ->
		@subscriptions.dispose()

	provideLinter: ->
		provider =
			grammarScopes: ['source.matlab']
			scope: 'file'
			lintOnFly: false
			lint: (textEditor) =>
				return new Promise (resolve, reject) =>
					filePath = textEditor.getPath()
					results = []
					process = new BufferedProcess
						command: if @mlintDir? then path.join(@mlintDir, "mlint") else "mlint"
						args: [filePath]
						stderr: (output) ->
							lines = output.split('\n')
							lines.pop()
							for line in lines
								# Lines of form:
								# L 22 (C 1-3): Invalid use of a reserved word.
								# L 22 (C 32): Parse error at ')': usage might be invalid MATLAB syntax.
								regex = /L (\d+) \(C (\d+)-?(\d+)?\): (.*)/
								[_, linenum, columnstart, columnend, message] = line.match(regex)
								if typeof columnend is 'undefined' then columnend = columnstart
								result = {
									range: [
										[linenum - 1, columnstart - 1],
										[linenum - 1, columnend - 1]
									]
									type: "warning"
									text: message
									filePath: filePath
								}
								results.push result
						exit: (code) ->
							return resolve [] unless code is 0
							return resolve [] unless results?
							resolve results

					process.onWillThrowError ({error,handle}) ->
						atom.notifications.addError "Failed to run MATLAB linter",
							detail: "Directory containing mlint is set to '#{atom.config.get("linter-matlab.mlintDir")}'"
							dismissable: true
						handle()
						resolve []

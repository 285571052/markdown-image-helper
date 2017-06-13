
{CompositeDisposable,File,Directory} = require 'atom'

module.exports = MarkdownImgHelper =

	activate: (state) ->
		atom.commands.onWillDispatch (e)  =>
			if e.type is "core:paste"

				editor = atom.workspace.getActiveTextEditor()
				return unless editor
				grammar = editor.getGrammar()
				return unless grammar
				return unless grammar.scopeName is 'source.gfm' or grammar.scopeName is 'text.tex.latex'


				clipboard = require 'clipboard'
				img = clipboard.readImage()

				return if img.isEmpty()

				e.stopImmediatePropagation()

				imgbuffer = img.toPng()

				thefile = new File(editor.getPath())
				assetsDirPath = thefile.getParent().getPath()+"/assets"


				crypto = require "crypto"
				md5 = crypto.createHash 'md5'
				md5.update(imgbuffer)

				pinyin = require "pinyin"
				filename = pinyin("#{thefile.getBaseName().replace(/\.\w+$/, '').replace(/\s+/g,'')}_#{md5.digest('hex').slice(0,5)}.png", {
				  style: pinyin.STYLE_NORMAL
				})
				filename = "#{filename}".replace(/,/g,'')

				@createDirectory assetsDirPath, ()=>
					@writePng assetsDirPath+'/', filename, imgbuffer, ()=>
						# ascClip = "assets/#{filename}"
						# clipboard.writeText(ascClip)

						@insertUrl "assets/#{filename}",editor

				return false

	createDirectory: (dirPath, callback)->
		assetsDir = new Directory(dirPath)

		assetsDir.exists().then (existed) =>
			if not existed
				assetsDir.create().then (created) =>
					if created
						console.log 'Success Create dir'
						callback()
			else
				callback()

	writePng: (assetsDir, filename, buffer, callback)->
		fs = require('fs')
		fs.writeFile assetsDir+filename, buffer, 'binary',() =>
			console.log('finish clip image')
			callback()

	insertUrl: (url,editor) ->
		editor.insertText(url)


	deactivate: ->


	serialize: ->

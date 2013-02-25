{ blað } = require 'blad'

marked = require 'marked'

class exports.ResourcesHolderDocument extends blað.Type

    render: (done) ->
        process = (doc) ->
            # Markdown?
            doc.body = marked doc.body if doc.body?
            doc
        # Fetch resources underneath us.
        @resources = ( process(ch) for ch in @children(0) when ch.type is 'ResourceDocument' )

        done @
{ blað } = require 'blad'

marked = require 'marked'

class exports.HomeDocument extends blað.Type

    render: (done) ->
        # Markdown?
        @body = marked @body if @body?

        # Fetch news documents.
        @news = ( for child in @children(1) when child.type is 'NewsDocument'
            child.body = marked child.body if child.body?
            child
        ).sort (a, b) ->
            if a.modified < b.modified then 1
            else
                if a.modified is b.modified then 0
                else -1

        done @
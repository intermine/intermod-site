{ blað } = require 'blad'

marked = require 'marked'

class exports.NewsDocument extends blað.Type

    render: (done) ->
        # Markdown?
        @body = marked @body if @body?

        done @
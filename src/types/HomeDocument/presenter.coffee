{ blað } = require 'blad'

marked = require 'marked'

class exports.HomeDocument extends blað.Type

    render: (done) ->
        # Markdown?
        @body = marked @body if @body?

        done @
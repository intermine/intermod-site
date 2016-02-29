{ blað } = require 'blad'

marked = require 'marked'

class exports.ProjectsHolderDocument extends blað.Type

    render: (done) ->
        # Get all current projects underneath and see if we have an archive.
        @archive = false
        @projects = []
        for p in @children(0)
            if p.current and p.type is 'ProjectDocument'
                if p.summary then p.summary = marked p.summary
                @projects.push p
            else
                @archive = true

        # Markdown.
        @body = marked @body
        
        # We done.
        done @
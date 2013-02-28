{ blað } = require 'blad'

marked = require 'marked'

class exports.HomeDocument extends blað.Type

    render: (done) ->
        # Markdown?
        @body = marked @body if @body?

        # Fetch news documents & mods.
        @news = [] ; mods = []
        for child in @children(1)
            switch child.type
                when 'NewsDocument'
                    child.body = marked child.body if child.body?
                    @news.push child
                when 'ModDocument'
                    mods.push child

        # Sort news on modification date.
        @news.sort (a, b) ->
            if a.modified < b.modified then 1
            else
                if a.modified is b.modified then 0
                else -1

        # Sort mods semi-randomly.
        mods.sort -> 0.5 - Math.random()

        # Make mods into groups of 3.
        @mods = [] ; idx = 0
        for i, obj of mods
            (@mods[idx] ?= []).push obj # push
            if (i + 1) % 3 is 0 then idx++ # move index

        done @
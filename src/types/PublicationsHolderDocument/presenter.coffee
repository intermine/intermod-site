{ blað } = require 'blad'

marked = require 'marked'
request = require 'request'
kronic = require 'kronic-node'
sax = require('sax').parser(true)

class exports.PublicationsHolderDocument extends blað.Type

    eSummary: 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id='

    render: (done) ->
        # Markdown biz.
        @body = marked @body if @body?

        # Get the latest ids.
        ids = @ids.replace(/\s/g, '').split(',')

        # Is our id cache different from latest ids?
        oldIds = @store.get 'pubmedPublicationIds'
        if oldIds and not (ids < oldIds or oldIds < ids)
            # Render the 'old' stuff.
            @publications = @store.get 'pubmedPublications'
            done @
        else
            # Save the new IDs.
            @store.save 'pubmedPublicationIds', ids, =>

                # Grab hold of the actual publications.
                request @eSummary + ids.join(','), (err, res, body) =>
                    if err or res.statusCode isnt 200 then done @
                    @xmlToPubs body, (pubmed) =>

                        # Reverse chronological order sort.
                        pubmed = pubmed.sort (a, b) ->
                            parseDate = (date) ->
                                return 0 if date is 0
                                
                                [ year, month, day ] = date.split(' ')
                                year = parseInt(year) ; month = month or 'Jan' ; day = parseInt(day) or 1
                                
                                p = kronic.parse([ day, month, year ].join(' '))
                                if p then p.getTime() else 0

                            if parseDate(b.PubDate) > parseDate(a.PubDate) then 1
                            else -1

                        # Cache the new data.
                        @store.save 'pubmedPublications', pubmed, =>
                            # Finally render.
                            @publications = pubmed
                            done @

    # Take eSearch XML and call back with ids.
    xmlToIds: (xml, cb) ->
        open = false ; ids = []
        
        sax.onopentag = (node) -> open = node.name is 'Id'
        sax.ontext = (text) -> if open and parseInt text then ids.push text
        sax.onend = -> cb ids.sort()
        
        sax.write(xml).close()

    # Take eSummary XML and call back with publications.
    xmlToPubs: (xml, cb) ->
        docs = [] ; doc = {} ; tag = {} ; authors = []

        sax.onattribute = (attr) -> tag[attr.name] = attr.value

        sax.onclosetag = (node) ->
            switch node
                when 'DocSum'
                    doc.Authors = authors
                    docs.push doc
                    doc = {} ; authors = []
                when 'Id'
                    doc.Id = tag.Text
                    tag = {}
                when 'Item'
                    switch tag.Name
                        when 'PubDate', 'FullJournalName', 'Title' then doc[tag.Name] = tag.Text
                        when 'Author' then authors.push tag.Text
                    tag = {}

        sax.ontext = (text) ->
            text = text.replace(/\s+/g, ' ')
            if text isnt ' ' then tag.Text = text

        sax.onend = -> cb docs

        sax.write(xml).close()
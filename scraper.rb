require 'mechanize'
require 'mongo'

db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'TRANSLATOR', :connect => :direct)

agent = Mechanize.new
page = agent.get("http://hyperpolyglot.org/scripting")
table = page.search(".wiki-content-table")[0]

languages = []

table.search("tr").map do |row|
    ths = row.search("th")

    # Ignore headers
    if (ths.length > 0 && languages.length > 0) || ths.length == 1
        next
    end

    # Get the languages
    if (ths.length > 0)
        ths.map do |th|
            if th.text == ""
                next
            end

            anchors = th.search("a")

            if anchors.length == 0
                next
            end

            text = anchors[0].text

            # meter check a ver se a lang n ta ja aqui
            #db[:languages].find(:commonName => text).each do |lang|

            #if results.map.length > 0
            #    languages << BSON::ObjectId(results[0].id)
            #else
                result = db[:languages].insert_one({
                    officialName: text,
                    commonName: text
                })

                languages << BSON::ObjectId(result.inserted_id)
            #end


        end
        next
    end

    featureId = ""

    row.search("td").map.each_with_index do |td, index|
        if index == 0
            result = db[:features].insert_one({
                title: td.search("a")[1].text,
                importance: 0,
                description: "",
                tags: []
            })

            featureId = BSON::ObjectId(result.inserted_id)
            next
        end

        db[:snippets].insert_one({
            feature: featureId,
            language: languages[index-1],
            code: td.text,
            tags: []
        })
    end
end

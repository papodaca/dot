class Opml
  def self.import(file_path, current_user)
    doc = File.open(file_path, 'r') { |opml| Nokogiri::XML.parse(opml.read) }

    get_elements(doc.xpath("/opml/body/outline")).each do |outline|
      import_outline(outline, current_user)
    end
  end

  def self.export(current_user)
    directories = current_user.directories.map(&:to_opml)
    <<~OPML
      <?xml version="1.0" encoding="UTF-8"?>
      <opml>
        <head>
          <title>#{current_user.email} subscriptions</title>
        </head>
        <body>
        #{directories}
        </body>
      </opml>
    OPML
  end

  class << self
    def import_outline(outline, current_user, parent = nil)
      type = outline.attributes["type"]
      type = type.text unless type.nil?
      if type.nil? && outline.children.size > 0
        dir = Directory.find_or_create_by(
          title: outline.attributes["title"].text,
          user_id: current_user.id
        )
        dir.parent = parent unless parent.nil?
        dir.save
        get_elements(outline).each { |ooutline| import_outline(ooutline, current_user, dir) }
      elsif type == "rss"
        Feed.find_or_create_by(
          title: outline.attributes["title"].text,
          url: outline.attributes["xmlUrl"].text,
          directory_id: parent.id
        )
      end
    end

    def get_elements(node)
      collection = if node.is_a?(Nokogiri::XML::Element)
        node.children
      else
        node
      end
      collection.select { |o| o.is_a?(Nokogiri::XML::Element) }
    end
  end
end

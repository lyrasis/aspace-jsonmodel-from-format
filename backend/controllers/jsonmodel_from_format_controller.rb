class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/plugins/jsonmodel_from_format/:type/:format') 
    .description("Convert :type by :format into a JSONModel equivalent")
    .params(["type", String, "Type"], ["format", String, "Format"])
    .permissions([:view_all_records])
    .returns([200, "Array of object :types"]) \
  do
    converter = get_converter params[:type], params[:format], request.body.read
    handle_response converter
  end

  private

  def converter_tree
    {
      accession: {
        csv: ->(content) { AccessionConverter.new( get_tempfile( parse_as_csv(content) ).path ) },
      },
      agent: {
        eac: ->(content) { EACConverter.new( get_tempfile( parse_as_xml(content) ).path ) },
      },
      digital_object: {
        csv: ->(content) { DigitalObjectConverter.new( get_tempfile( parse_as_csv(content) ).path ) },
      },
      resource: {
        ead: ->(content) { EADConverter.new( get_tempfile( parse_as_xml(content) ).path ) },
        marcxml: ->(content) { MarcXMLConverter.new( get_tempfile( parse_as_xml(content) ).path ) },
      },
    }
  end

  def get_converter(type, format, content)
    converter = converter_tree[type.intern][format.intern]
    converter.call content
  end

  # from the aspace source =)
  def get_tempfile(content)
    tmp = ASUtils.tempfile("doc-#{Time.now.to_i}")
    tmp.write(content)
    tmp.flush
    $icky_hack_to_avoid_gc ||= []
    $icky_hack_to_avoid_gc << tmp
    tmp
  end

  def handle_response(converter)
    converter.run
    content_type :json
    parsed = JSON(IO.read(converter.get_output_path))
    JSON.generate(parsed)   
  end

  def parse_as_csv(content)
    CSV.parse(content) # check it's parseable
    content
  end

  def parse_as_xml(content)
    Nokogiri::XML(content).to_s
  end

end

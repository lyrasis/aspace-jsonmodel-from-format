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
        csv: ->(content) { init_converter(AccessionConverter, :parse_as_csv, content) },
      },
      agent: {
        eac: ->(content) { init_converter(EACConverter, :parse_as_xml, content) },
      },
      digital_object: {
        csv: ->(content) { init_converter(DigitalObjectConverter, :parse_as_csv, content) },
      },
      resource: {
        ead: ->(content) { init_converter(EADConverter, :parse_as_xml, content) },
        marcxml: ->(content) { init_converter(MarcXMLConverter, :parse_as_xml, content) },
      },
    }
  end

  def get_converter(type, format, content)
    converter = converter_tree[type.to_sym][format.to_sym]
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

  def init_converter(converter_type, parser_type, content)
    # check we can parse content and get tmp file
    tmpfile = get_tempfile( self.send(parser_type, content) )
    # init new converter
    converter = converter_type.send(:new, tmpfile.path)
    # run the converter now to generate the output
    converter.run
    # remove the tmpfile handle and delete the file
    tmpfile.close!
    # return converter
    converter
  end

  def handle_response(converter)
    content_type :json
    output_path = converter.get_output_path
    parsed = JSON(IO.read(output_path))
    File.unlink(output_path) # needed ???
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

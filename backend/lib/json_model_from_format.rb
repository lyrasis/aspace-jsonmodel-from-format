module ArchivesSpace

  class JsonModelFromFormat

    attr_reader :parsed_data

    def initialize(converter_class, parse_method, content)
      @converter_class = converter_class
      @parse_method    = parse_method
      @content         = content
      @parsed_data     = nil
    end

    def run
      converter    = run_converter
      output_path  = converter.get_output_path
      data         = JSON(IO.read(output_path))
      @parsed_data = JSON.generate(data)

      File.unlink(output_path)
      @parsed_data
    end

    def run_converter
      # check we can parse content
      parsed_data = self.send(@parse_method)
      # write parsed data to tmpfile
      tmpfile = JsonModelFromFormat.write_tempfile(parsed_data)
      # init new converter
      converter = @converter_class.send(:new, tmpfile.path)
      # run the converter now to generate the output
      converter.run
      # remove the tmpfile handle and delete the file
      tmpfile.close!
      # return converter
      converter
    end

    def parse_as_csv
      CSV.parse(@content) # simply check it's parsable
      @content
    end

    def parse_as_xml
      Nokogiri::XML(@content).to_s
    end

    # from the aspace source =)
    def self.write_tempfile(content)
      tmp = ASUtils.tempfile("doc-#{Time.now.to_i}")
      tmp.write(content)
      tmp.flush
      $icky_hack_to_avoid_gc ||= []
      $icky_hack_to_avoid_gc << tmp
      tmp
    end

  end

end
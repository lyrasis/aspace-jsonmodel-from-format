# frozen_string_literal: true

# require files from lib
Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')).sort.each do |file|
  require File.absolute_path(file)
end

unless AppConfig.has_key?(:converter_tree)
  # default converter tree (should match what aspace provides)
  AppConfig[:converter_tree] = {
    accession: {
      csv: {
        converter_class: AccessionConverter,
        parse_method: :parse_as_csv
      },
      marcxml: {
        converter_class: MarcXMLBibAccessionConverter,
        parse_method: :parse_as_xml
      }
    },
    agent: {
      eac: {
        converter_class: EACConverter,
        parse_method: :parse_as_xml
      },
      marcxml: {
        converter_class: MarcXMLAuthAgentConverter,
        parse_method: :parse_as_xml
      }
    },
    digital_object: {
      csv: {
        converter_class: DigitalObjectConverter,
        parse_method: :parse_as_csv
      }
    },
    resource: {
      ead: {
        converter_class: EADConverter,
        parse_method: :parse_as_xml
      },
      marcxml: {
        converter_class: MarcXMLBibConverter,
        parse_method: :parse_as_xml
      }
    }
  }
end

# frozen_string_literal: true

class ArchivesSpaceService < Sinatra::Base
  Endpoint.post('/plugins/jsonmodel_from_format/:type/:format')
          .description('Convert :type by :format into a JSONModel equivalent')
          .params(['type', String, 'Type'], ['format', String, 'Format'])
          .permissions([:view_all_records])
          .returns([200, 'Array of object :types']) \
  do
    # TODO: better error handling
    converter_tree  = AppConfig[:converter_tree]
    converter_class = converter_tree[params[:type].to_sym][params[:format].to_sym][:converter_class]
    parse_method    = converter_tree[params[:type].to_sym][params[:format].to_sym][:parse_method]
    content         = request.body.read
    converter       = ArchivesSpace::JsonModelFromFormat.new(converter_class, parse_method, content)
    content_type :json
    converter.run # returns json
  end
end

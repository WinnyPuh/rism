# frozen_string_literal: true

module IndexSearchHelper
  def index_search(search_fields, options = {})
    options[:placeholder] ||= t('placeholders.search')
    options[:size] ||= 50
    render 'helpers/index_search', search_fields: search_fields,
                                   options: options
  end
end

class CreateIndicatorsService
  def self.call(*args, &block)
    new(*args, &block).execute
  end

  def initialize(text, investigation_id, user_id)
     @text = text
     @investigation_id = investigation_id
     @user_id = user_id
  end

  def execute
    @text.split("\n")
         .select do |string|
           next if string.blank?
           string unless create_indicator(string)
          end
  end

  private

  def create_indicator(string)
    string.strip!
    indicator_params = Indicator.cast_indicator(string)
    return unless indicator_params.fetch(:content_format, false)
    indicator_params[:indicator_context_ids] = indicator_context_ids(
      indicator_params[:indicator_context_ids]
    )
    indicator_params.merge!(
      investigation_id: @investigation_id,
      user_id: @user_id,
      trust_level: :unknown,
      enrichment: {}
    )
    indicator = Indicator.new(indicator_params)
    indicator.current_user = User.find(@user_id)
    indicator.skip_format_validation = true
    indicator.save
  end

  def indicator_context_ids(codenames)
    return if codenames.blank?
    codenames.split(',').map(&:strip).each_with_object([]) do |codename, ids|
      ids << IndicatorContext.find_by(codename: codename).id
    end
  end
end

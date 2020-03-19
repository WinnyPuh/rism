# frozen_string_literal: true

class Api::CustomReportsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  #before_action :authenticate

  skip_before_action :set_paper_trail_whodunnit
  skip_before_action :authenticate?
  skip_after_action :log_user_action
  skip_after_action :verify_authorized

  # Download custom report file throught API.
  # Examles of usage (3 is a custom report ID):
  # download as file -
  # curl -O -J http://localhost:3000/api/custom_reports/3
  # show downloaded content in console (or transfer it to another app through pipe) -
  # curl http://localhost:3000/api/custom_reports/3
  # transfer downloaded content to another app through pipe -
  # curl http://localhost:3000/api/custom_reports/3 | grep some_text
  def show
    last_result = set_last_result
    send_file(
      last_result.result_path,
      filename: last_result.result_file,
      disposition: 'attachment',
      x_sendfile: true
    )
  end

  private

  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @current_user = User.find_by(api_key: token)
    end
  end

  def render_unauthorized(realm = "Application")
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm}")
    render json: 'Bad credentials', status: :unauthorized
  end

  def set_last_result
    custom_report = CustomReport.find(params[:id])
    custom_report.last_result
  end
end

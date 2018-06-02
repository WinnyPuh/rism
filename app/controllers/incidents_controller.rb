# frozen_string_literal: true

class IncidentsController < ApplicationController
  include RecordOfOrganization

  before_action :set_time, only: [:create, :update]

  def search
    authorize model
    @organization = organization
    if @organization.id
      @records = records(filter_for_organization)
      render 'index'
    else
      @records = records(model)
      render 'application/index'
    end
  end

  private

  def model
    Incident
  end

  def records(scope)
    scope = policy_scope(scope)
    @q = scope.ransack(params[:q])
    @q.sorts = default_sort if @q.sorts.empty?
    @q.result(distinct: true)
      .joins(:user) # For line below
      .select('incidents.*, users.name AS user_name')# Postrges dont allow use DISTINCT with ORDER BY by field that not in SELECT
      .joins(:tag_kinds) # For line below
      .where(tag_kinds: {record_type: 'Incident'}) # Filter only incident specific tags
      .preload(records_includes) # Explicitly preload used in index records
      .page(params[:page])
  end

# filter used in index pages wich is a part of organizaion show page
# (such index shows only records that belongs to organization)
#  def filter_for_organization
#    @organization.me_linked_incidents.group(:id)
#  end

  def default_sort
    'created_at desc'
  end

  def records_includes
    # exclude unused :organizations includes
    # when user is global admin, editor or reader
    # ( user can access to all organizations)
    # TODO: resolve Bullet N+1 alerts
    [:user, :incident_organizations, incident_tags: :tag_kind].tap do |associations|
      associations << :organization unless current_user.admin_editor_reader?
    end
  end

  def set_time
    %w[discovered started finished].each do |field|
    hours = params[:incident]["#{field}_at(4i)"]
    minutes = params[:incident]["#{field}_at(5i)"]
      if hours.present? && minutes.present?
        params[:incident]["#{field}_time"] = '1'
      else
        params[:incident]["#{field}_time"] = '0'
      end
    end
  end
end

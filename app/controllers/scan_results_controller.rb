# frozen_string_literal: true

class ScanResultsController < ApplicationController
  include RecordOfOrganization

  def index
    authorize_model
    if @organization.id
      @records = records(filter_for_organization)
      render 'organization_index'
    else
      @records = records(model)
      render 'index'
    end
  end

  def open_ports
    authorize_model
    if @organization.id
      @records = open_ports_records(filter_for_organization)
      render 'organization_open_ports'
    else
      @records = open_ports_records(model)
      render 'open_ports'
    end
  end

  def new_ports
    authorize_model
    if @organization.id
      @records = new_ports_records(filter_for_organization)
      render 'organization_new_ports'
    else
      @records = new_ports_records(model)
      render 'new_ports'
    end
  end

  private

  def authorize_model
    authorize model
    @organization = organization
  end

  def open_ports_records(scope)
    scope = policy_scope(scope)
    scope = scope.where(state: :open)
    scope = ScanResultsQuery.new(scope)
                           .last_results
    @q = scope.ransack(params[:q])
    @q.sorts = default_sort if @q.sorts.empty?
    @q.result(distinkt: true)
      .includes(records_includes)
      .page(params[:page])
  end

  def new_ports_records(scope)
    scope = policy_scope(scope)
    scope = scope.where(state: :open)
    scope = ScanResultsQuery.new(scope)
                           .last_results
    scope = ScanResultsQuery.new(scope)
                            .not_registered_services
    @q = scope.ransack(params[:q])
    @q.sorts = default_sort if @q.sorts.empty?
    @q.result(distinkt: true)
      .includes(records_includes)
      .page(params[:page])
  end

  def model
    ScanResult
  end

  def default_sort
    'finished desc'
  end

  def records_includes
    %i[organization]
  end

  def filter_for_organization
    model.joins('JOIN hosts ON scan_results.ip <<= hosts.ip')
         .where('hosts.organization_id = ?', @organization.id)
  end
end

# frozen_string_literal: true

class HostsReport < BaseReport
  include DateTimeHelper

  set_lang :ru
  set_report_name :hosts
  set_human_name 'Хосты'
  set_report_model 'Host'
  set_required_params %i[]

  def report(r)
    r.page_size do
      width       16837 # sets the page width. units in twips.
      height      11905 # sets the page height. units in twips.
      orientation :landscape  # sets the printer orientation. accepts :portrait and :landscape.
    end
    if options[:organization_id].present?
      organization = OrganizationPolicy::Scope.new(current_user, Organization).resolve.where(id: options[:organization_id]).first
      r.p  "Справка по хостам организации #{organization.name}", style: 'Header'
    else
      r.p  "Справка по хостам организаций", style: 'Header'
    end
    r.p  "(по состоянию на #{Date.current.strftime('%d.%m.%Y')})", style: 'Prim'


    scope = Host
    if organization.present?
      scope = scope.where(organization_id: organization.id)
    end

    records = Pundit.policy_scope(current_user, scope)
      .includes(:organization)
      .order('organizations.name')
      .order(:ip)

    header = [[
      'Организация',
      'IP-адрес/подсеть',
      'Описание'
    ]]

    table = records.each_with_object(header) do |record, memo|
      row = []
      record = HostDecorator.new(record)
      row << "#{record.organization.name}"
      row << "#{record.show_ip}"
      row << "#{record.description}"
      memo << row
    end
    r.p
    r.table(table, border_size: 4) do
      cell_style rows[0],    bold: true,   background: '3366cc', color: 'ffffff'
      cell_style cells,      size: 20, margins: { top: 100, bottom: 0, left: 100, right: 100 }
     end
  end
end

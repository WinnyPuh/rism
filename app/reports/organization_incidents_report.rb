# frozen_string_literal: true

# To add report - add class (shown below) file into app/reports
# and register in in reports.rb:
#
#  OrganizationIncidentsReport.register
class OrganizationIncidentsReport < BaseReport
  set_lang :ru
  set_report_name :organization_incidents
  set_human_name 'Инциденты организации'
  set_report_model 'Incident'
  set_required_params %i[organization_id]

  def report(r)
    #docx.page
    organization = OrganizationPolicy::Scope.new(current_user, Organization).resolve
      .where(id: options[:organization_id]).first

    # docx.h1 'Справка по инцидентам организации'
    # docx.hr
    r.p  "Справка по инцидентам связанным c организацией #{organization.name}", style: 'Header'
#      docx.ul do
#        li 'Custom page sizes and margins'
#        li 'Custom styles (including the manipulation of font, size, color, alignment, margins, leading, etc.)'
#        li 'Paragraph text, headings, and external links'
#        li 'Ordered and unordered lists'
#        li 'Images'
#        li 'Tables'
#        li 'Page numbers'
#      end
    organization.me_linked_incidents.each_with_index do |incident, index|
      r.p
      r.p "#{index + 1}. Инцидент ID #{incident.id} (#{incident.name})", style: 'Header'
      r.p "Когда зарегистрирован: #{incident.created_at.strftime('%d.%m.%Y-%H:%M')}", style: 'Text'
      r.p "Когда обнаружен: #{IncidentDecorator.new(incident).show_discovered_at}", style: 'Text'
      r.p "Когда начался: #{IncidentDecorator.new(incident).show_started_at}", style: 'Text'
      r.p "Когда завершился: #{IncidentDecorator.new(incident).show_finished_at}", style: 'Text'
      r.p "Статус: #{IncidentDecorator.new(incident).show_state}", style: 'Text'
      r.p "Ущерб: #{IncidentDecorator.new(incident).show_damage}", style: 'Text'
      r.p "Важность: #{IncidentDecorator.new(incident).show_severity}", style: 'Text'
      r.p incident.event_description, style: 'Text'
      r.p incident.investigation_description, style: 'Text' if incident.investigation_description.present?
      r.p incident.action_description, style: 'Text' if incident.action_description.present?
      incident.links.group_by { |link| "#{LinkKindDecorator.new(link.link_kind).name}" }.sort.each do |link_kind_name, links|
      r.p style: 'Text' do
          text "#{link_kind_name}: "
          links.each do |link|
            text "#{link.second_record.show_full_name}"
            text "#{link.description}"
          end
        end
      end
      incident.tag_members.group_by { |tag_member| "#{tag_member.tag.tag_kind.name}" }.sort.each do |tag_kind, tag_members|
        r.p style: 'Text' do
          text "#{tag_kind}: "
          tag_members.each do |tag_member|
            text "#{tag_member.tag.name}"
          end
        end
      end
    end
#      docx.h2 'Simple Tables'
#      docx.table [[1], [2], [3], [4]], border_size: 4 do
#        cell_style rows[0],    bold: true,   background: '3366cc', color: 'ffffff'
#        cell_style rows[-1],   bold: true,   background: 'dddddd'
#        cell_style cells[2],   italic: true, color: 'cc0000'
#        cell_style cols[0],    width: 6000
#        cell_style cells,      size: 18, margins: { top: 100, bottom: 0, left: 100, right: 100 }
#      end
  end
end

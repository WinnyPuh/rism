# frozen_string_literal: true

class DeleteAllShodanScansCommand < BaseCommand

  set_command_name :delete_all_shodan_scans
  set_human_name 'Удалить все Shodan результаты сканирования'
  set_command_model 'ScanResult'
  set_required_params %i[]

  def run
    scope = ScanResult
    if options[:organization_id].present?
      scope = scope.where(organization_id: options[:organization_id])
    end
    scope = scope.joins(:scan_job).where(scan_jobs: {scan_engine: 'shodan'})

    Pundit.policy_scope(current_user, scope).destroy_all
  end
end

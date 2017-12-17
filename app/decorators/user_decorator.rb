class  UserDecorator < SimpleDelegator
  def show_active
    active ? I18n.t('labels.user.active') : I18n.t('labels.user.not_active')
  end

  def contact
    result = []
    result << name if name.present?
    result << job if job.present?
    result << "#{I18n.t('labels.user.phone')} #{phone}" if phone.present?
    result.join(', ')
  end

  def full_job
    result = []
    result << job if job.present?
    dep_name = department&.name || department_name
    result << dep_name if dep_name.present?
    result.join(', ')
  end

  def dep_name
    department&.name || department_name || ''
  end
end

class CommandPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def run?
    return true if @user.admin_editor_reader?
    @user.can? :edit, 'Commands'
  end
end

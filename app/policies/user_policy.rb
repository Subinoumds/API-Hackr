class UserPolicy < ApplicationPolicy

  def new?
    true
  end

  def create?
    true
  end

  def index?
    true
  end

  def show?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def check_email?
    true
  end

  def generate_fake_identity?
    true
  end

  def check_email_existence?
    true
  end

  def is_common_password?
    true
  end
end

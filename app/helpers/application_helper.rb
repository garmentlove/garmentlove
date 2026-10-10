module ApplicationHelper
  def app_name
    Rails.application.class.name.split("::").first.upcase
  end
end

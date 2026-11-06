class App::BaseController < ApplicationController
  layout "portal"

  private
    def cookie_key
      :app_session_id
    end
end

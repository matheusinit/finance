class PageController < ApplicationController
  skip_before_action :require_login

  def home
    render layout: "landing_page"
  end
end

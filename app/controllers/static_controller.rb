class StaticController < ApplicationController
  def contact

  end
  def policies
    Pageview.create(search: false, page: "Policies")
  end
end

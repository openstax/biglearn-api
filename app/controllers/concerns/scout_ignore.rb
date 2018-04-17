module ScoutIgnore
  # Not a real ActiveSupport::Concern but no reason it couldn't be

  def scout_ignore!(fraction = 1.0)
    ScoutApm::RequestManager.lookup.ignore_request! if rand <= fraction
  end
end

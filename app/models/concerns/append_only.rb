module AppendOnly
  extend ActiveSupport::Concern

  def readonly?
    !new_record?
  end
end

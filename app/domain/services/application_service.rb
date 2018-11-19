class Services::ApplicationService
  def self.process(*args)
    new.process(*args)
  end

  def process(*args)
    raise NotImplementedError
  end
end

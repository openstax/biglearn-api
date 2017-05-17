class Services::ApplicationService
  def process(*args)
    raise NotImplementedError
  end

  def self.process(*args)
    new.process(*args)
  end
end

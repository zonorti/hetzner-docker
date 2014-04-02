require "hetzner-docker/version"
require "hetzner-docker/rescuemode"
require "hetzner-docker/ubuntu"
require "hetzner-docker/chefbootstrap"

class HetznerHost
  include HetznerDocker

  def initialize(init)
    @opts = init
    puts opts[:ip]
  end
end

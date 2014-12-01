require 'hetzner-docker/version'
require 'hetzner-docker/rescuemode'
require 'hetzner-docker/ubuntu'
require 'hetzner-docker/debian'
require 'hetzner-docker/centos'
require 'hetzner-docker/coreos'
require 'hetzner-docker/chefbootstrap'
require 'hetzner-docker/chefrun'
require 'hetzner-docker/tools'

class HetznerHost
  include HetznerDocker

  def initialize(init)
    init.each_pair do |key, val|
      instance_variable_set('@' + key.to_s, val)
    end
    unless defined?(@user)
      @user='root'
    end
    unless defined?(@hostname) and @hostname != nil
      @hostname="docker#{SecureRandom.hex(3)+@ip.rpartition(".")[2]}"
    end
    unless defined?(@domain) and @domain != nil
      @domain="twiket.com" # this is our default, sorry
    end
    unless defined?(@url) and @url != nil
      @url="https://raw.githubusercontent.com/iMelnik/hetzner-docker/master/do-install-trusty.sh" 
    end

  end
  def user
    @user
  end
  def hostname
    @hostname
  end

end

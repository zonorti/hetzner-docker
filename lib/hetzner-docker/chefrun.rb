require 'chef'
require 'chef/knife'
require 'chef/knife/ssh'
require 'chef/knife/solo_cook'

require 'berkshelf'
require 'erubis'
require 'pathname'

require 'knife-solo'
require 'knife-solo/ssh_command'
require 'knife-solo/berkshelf'
require 'knife-solo/node_config_command'
require 'knife-solo/ssh_connection'
require 'knife-solo/tools'

class HetznerHost
  def run_chef
    kb = Chef::Knife::SoloCook.new
    kb.config[:ssh_user]            = @user
    kb.config[:override_runlist]            = "docker"
    kb.config[:librarian]            = false
    kb.config[:host_key_verify]            = false
    kb.name_args                    = [@ip]
    kb.run
  end
end

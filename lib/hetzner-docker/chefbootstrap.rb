require 'chef'
require 'chef/knife'
require 'chef/knife/bootstrap'
require 'chef/knife/ssh'
require 'chef/knife/solo_prepare'
require 'knife-solo/bootstraps'
require 'knife-solo/ssh_command'
require 'knife-solo/node_config_command'
require 'knife-solo/ssh_connection'

class HetznerHost
  def bootstrap_chef
    kb = Chef::Knife::SoloPrepare.new
    kb.config[:ssh_user]            = @user
    kb.name_args                    = [@ip]
    Chef::Config[:knife][:bootstrap_version]     = @bootstrap_version
    kb.run
  end
end

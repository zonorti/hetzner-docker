require 'net/ssh'
require 'net/scp'


class HetznerHost
  def install_ubuntu
    puts "Goint to install ubuntu at #{@ip}"
    Net::SSH.start(@ip, @user) do |ssh|
      ssh.scp.upload! File.expand_path(Dir.pwd+"/do-install-trusty.sh"), "/root/do-install-trusty.sh"
      puts "bash installer copied to #{@hostname}"
      ssh.exec "/root/do-install-trusty.sh #{@hostname}"
    end
    clear_known_key
  end
end

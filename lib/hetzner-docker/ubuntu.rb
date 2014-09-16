require 'net/ssh'
require 'net/scp'


class HetznerHost
  def install_ubuntu
    puts "Goint to install ubuntu at #{@ip}"
    Net::SSH.start(@ip, @user) do |ssh|
      ssh.scp.upload! "do-install-trusty.sh", "/root/do-install-trusty.sh"	do |ch, name, sent, total|
    	puts "#{name}: #{sent}/#{total}"
  	  end
      ssh.exec "/bin/bash /root/do-install-trusty.sh #{@hostname} #{@domain}"
    end
    clear_known_key
    wait_for_reboot
    put_key
    puts "Fresh ubuntu installed at #{@ip}"
  end
end

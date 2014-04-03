require 'net/ssh'
require 'net/scp'


class HetznerHost
  def install_ubuntu
    puts "Goint to install ubuntu at #{@ip}"
    Net::SSH.start(@ip, @user) do |ssh|
      ssh.exec "wget #{@url} -O /root/do-install-trusty.sh && /bin/bash /root/do-install-trusty.sh #{@hostname} #{@domain}"
    end
    clear_known_key
    wait_for_reboot
    puts "Fresh ubuntu installed at #{@ip}"
  end
end

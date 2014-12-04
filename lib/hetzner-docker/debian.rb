require 'net/ssh'
require 'net/scp'

# Debian installer class
class HetznerHost
  def install_debian
    puts "Goint to install debian at #{@ip}"
    Net::SSH.start(@ip, @user) do |ssh|
      ssh.scp.upload! 'do-install-wheezy.sh', '/root/do-install-wheezy.sh'  do |name, sent, total|
        puts "#{name}: #{sent}/#{total}"
      end
      ssh.exec "/bin/bash /root/do-install-wheezy.sh #{@hostname} #{@domain}"
      puts 'Provisioned'
    end
    clear_known_key
    wait_for_reboot
    put_key
    puts "Fresh debian installed at #{@ip}"
    install_proxmox
    wait_for_reboot
    puts "PVE installed at #{@ip}"
  end

  def install_proxmox
    Net::SSH.start(@ip, @user) do |ssh|
      ssh.scp.upload! 'do-install-proxmox.sh', '/root/do-install-proxmox.sh'  do |name, sent, total|
        puts "#{name}: #{sent}/#{total}"
      end
      ssh.exec '/bin/bash /root/do-install-proxmox.sh'
      puts 'Provisioned'
    end
  end
end

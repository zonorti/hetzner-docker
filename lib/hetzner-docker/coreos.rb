require 'net/ssh'
require 'net/scp'


class HetznerHost
  def install_coreos
    puts "Goint to install coreos at #{@ip}"
    cloud_config=`cat cloud-config.yaml | sed s/EXTIP/#{@ip}/g | sed  's/HOSTNAME/#{hostname}/g'`
    Net::SSH.start(@ip, @user) do |ssh|
      #puts cloud_config
      ssh.exec "cat >/run/cloud-config.yaml <<EOF #cloud-config\n#{cloud_config} \nEOF"
      ssh.exec "wget --quiet https://raw.github.com/coreos/init/master/bin/coreos-install -O /root/coreos-install && /bin/bash /root/coreos-install -d /dev/sda -c /run/cloud-config.yaml && reboot"
    end
    clear_known_key
    wait_for_reboot
    puts "Fresh coreos installed at #{@ip}"
  end
end

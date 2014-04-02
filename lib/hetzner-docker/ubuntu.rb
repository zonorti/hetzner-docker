require 'net/ssh'


class HetznerHost
  def install_ubuntu
    puts "Goint to install ubuntu at #{@opts[:ip]}"
    system("ssh-keygen -q -R #{ip}")
    puts "Waiting for #{ip}..." until test_ssh(ip)
    identity_file = File.expand_path(DEFAULT_IDENTITY_FILE)
    puts identity_file
    Net::SSH.start(ip, username, :password => password) do |ssh|
      ssh.scp.upload! File.expand_path(File.dirname(__FILE__)+"/do-install-trusty.sh"), "/root/do-install-trusty.sh"
      puts "bash installer copied"
      ssh.exec "/root/do-install-trusty.sh #{hostname}"
    end
    system("ssh-keygen -q -R #{ip}")

  end

end


def put_key
  Net::SSH.start(ip, username, :password => password) do |ssh|
    ssh.exec "test -d ~/.ssh || mkdir ~/.ssh"
    if password
      ssh.scp.upload! identity_file, "/root/.ssh/authorized_keys"
      puts "ssh identity copied"
    end
  end
end

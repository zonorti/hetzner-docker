require 'net/ssh'
require 'net/scp'
require 'timeout'

class HetznerHost
  def put_key
    puts "installing ssh key"
    clear_known_key
    identity_file = File.expand_path(DEFAULT_IDENTITY_FILE)
    Net::SSH.start(@ip, @user, :password => @password) do |ssh|
      ssh.exec "test -d ~/.ssh || mkdir ~/.ssh"
      if @password
        ssh.scp.upload! identity_file, "/root/.ssh/authorized_keys"
        puts "ssh identity copied"
      end
    end
  end

  def clear_known_key
    puts "clearing local ssh host key"
    system("ssh-keygen -q -R #{@ip} >/dev/null")
  end

  def wait_for_reboot
    while ssh_available?
      puts "waiting for ssh on #{@ip} to go away"
      sleep 1
    end
    puts "Waiting for ssh on #{@ip}..." until ssh_available?
  end

  def ssh_available?(port = 22)
    socket = TCPSocket.new(@ip, port)
    IO.select([socket], nil, nil, 5)
  rescue SocketError, Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
      sleep 2
      false
  rescue Errno::EPERM, Errno::ETIMEDOUT
      false
  ensure
      socket && socket.close
  end

  def in_rescue_mode?
    Timeout::timeout(5) {
      Net::SSH.start(@ip, "root", :password => @password,
                   :paranoid => false,
                   :verbose => :warn) do |ssh|
        hostname =  ssh.exec!("hostname")
        status = hostname.start_with?("rescue")
        status ? true : false
      end
    }
  rescue Net::SSH::AuthenticationFailed,
         Errno::ECONNREFUSED,
         Errno::ECONNRESET,
         Errno::EHOSTUNREACH,
         Errno::ENETUNREACH,
         Errno::ETIMEDOUT,
         SocketError,
         IOError,
         Timeout::Error
    false
  end
end

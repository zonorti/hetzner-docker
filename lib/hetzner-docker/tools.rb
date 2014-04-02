require 'net/ssh'
require 'net/scp'

class HetznerHost
  def put_key
  	clear_known_key
    puts "Waiting for #{@ip}..." until test_ssh
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
    system("ssh-keygen -q -R #{@ip} >/dev/null")
  end

  def test_ssh(port = 22)
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
end

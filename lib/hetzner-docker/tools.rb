require 'net/ssh'

class HetznerHost
  def put_key
    Net::SSH.start(ip, username, :password => password) do |ssh|
      ssh.exec "test -d ~/.ssh || mkdir ~/.ssh"
      if password
        ssh.scp.upload! identity_file, "/root/.ssh/authorized_keys"
        puts "ssh identity copied"
      end
    end
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

require 'hetzner-api'

class HetznerHost
  def install_centos
    puts "Installing CentOS!"
    hetzner = Hetzner::API.new ENV['HETZNER_USER'], ENV['HETZNER_PASSWORD']
    server = hetzner.server? @ip

    if server.parsed_response.has_key?("server")
      hostname = server.parsed_response["server"]["server_name"]
      puts "Resetting #{hostname} at #{@ip}"
    else
      raise server.parsed_response["error"]["message"]
    end

    hetzner.disable_rescue! @ip
    result = hetzner.boot_linux!(@ip,"CentOS 7.0 minimal", "64", "en" )

    if result.parsed_response.has_key?("linux")
      @password = result.parsed_response["linux"]["password"]
      puts @password
      hetzner.reset! @ip, 'sw'
      wait_for_reboot
      put_key
      puts "Wait while CentOS is being installed"
      wait_for_reboot
      put_key
      puts "CentOS installed" 
    else
      raise result.parsed_response["error"]["message"]
    end


  end


end

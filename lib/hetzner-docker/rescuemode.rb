require 'hetzner-api'

class HetznerHost
  def rescuemode
    puts "to the rescue!"
    hetzner = Hetzner::API.new ENV['HETZNER_USER'], ENV['HETZNER_PASSWORD']
    server = hetzner.server? @ip

    if server.parsed_response.has_key?("server")
      hostname = server.parsed_response["server"]["server_name"]
      puts "Resetting #{hostname} at #{@ip}"
    else
      raise server.parsed_response["error"]["message"]
    end

    hetzner.disable_rescue! @ip
    result = hetzner.enable_rescue! @ip

    if result.parsed_response.has_key?("rescue")
      @password = result.parsed_response["rescue"]["password"]
      puts @password
      reset = hetzner.reset! @ip, 'sw'
      while test_ssh
        sleep 1
      end
      put_key
    else
      raise result.parsed_response["error"]["message"]
    end


  end


end

require 'factor-connector-api'
require 'net/ssh'
require 'net/scp'
require 'tempfile'
require 'uri'

Factor::Connector.service 'chef' do
  action 'bootstrap' do |params|
    host_param     = params['host']
    private_key    = params['private_key']
    validation_key = params['validation_key']
    runlist        = params['runlist']
    organization   = params['organization']
    node_name      = params['name']

    fail 'Host is required' unless host_param
    fail 'Private Key (private_key) is required' unless private_key
    fail 'Validation Key (validation_key) is required' unless validation_key
    fail 'Organization (organization) is required' unless organization
    fail 'Runlist (runlist) is required' unless runlist
    fail 'Node Name (name) is required' unless node_name

    validation_name = params['validation_name'] || "#{organization}-validator"


    info 'Setting  up the client.rb file'
    client_rb = ""
    client_rb << "log_location STDOUT\n"
    client_rb << "chef_server_url  \"https://api.opscode.com/organizations/#{organization}\"\n"
    client_rb << "validation_client_name \"#{validation_name}\"\n"
    client_rb << "node_name \"#{node_name}\"\n"



    info 'Setting up private key'
    begin
      private_key_file = Tempfile.new('private')
      private_key_file.write(private_key)
      private_key_file.close
    rescue
      fail 'Failed to setup private key'
    end

    begin
      uri       = URI("ssh://#{host_param}")
      host      = uri.host
      port      = uri.port
      user      = uri.user
    rescue => ex
      fail "Couldn't parse input parameters", exception: ex
    end

    ssh_settings = { keys: [private_key_file.path] }
    ssh_settings[:port] = port if port

    fail 'User (user) is required in host address' unless user
    fail 'Host variable must specific host address' unless host

    setup_commands = [
      'curl -L https://www.opscode.com/chef/install.sh | sudo bash',
      'mkdir -p /etc/chef',
      'cd /etc/chef',
    ]

    run_commands = [
      "chef-client --runlist #{runlist}"
    ]

    output = []
    begin
      Net::SSH.start(host, user, ssh_settings) do |ssh|

        info 'Running setup commands'
        setup_commands.each do |command|
          info "  running '#{command}'"
          returned = ssh.exec!(command)
          if returned && returned.is_a?(String)
            lines = returned.split("\n")
            lines.each do |line|
              info "    #{line}"
            end
            output = output + lines
          end
        end

        info 'Uploading /etc/chef/validation.pem'
        validation_string_io     = StringIO.new(validation_key)
        ssh.scp.upload!(validation_string_io, '/etc/chef/validation.pem')

        info 'Uploading /etc/chef/client.rb'
        client_string_io     = StringIO.new(client_rb)
        begin
          ssh.scp.upload!(client_string_io, '/etc/chef/client.rb')
        rescue
          fail "Failed to upload /chef/client.rb"
        end

        info 'Running chef bootstrap commands'
        run_commands.each do |command|
          info "  running '#{command}'"
          returned = ssh.exec!(command)
          if returned && returned.is_a?(String)
            lines = returned.split("\n")
            lines.each do |line|
              info "    #{line}"
            end
            output = output + lines
          end
        end
      end
    rescue Net::SSH::AuthenticationFailed
      fail 'Authentication failure, check your SSH key, username, and host'
    rescue => ex
      fail "Couldn't connect to the server #{user}@#{host}:#{port || '22'}, please check credentials.", exception:ex
    end

    info 'Cleaning up.'
    begin
      private_key_file.unlink
      validation_key_file.unlink
    rescue
      warn 'Failed to clean up, but no worries, work will go on.'
    end

    action_callback output: output
  end
end
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
    environment    = params['environment']

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

    ssh_settings = { keys: [private_key_file.path], paranoid: false }
    ssh_settings[:port] = port if port

    fail 'User (user) is required in host address' unless user
    fail 'Host variable must specific host address' unless host

    install_command = 'curl -L https://www.opscode.com/chef/install.sh | sudo bash'
    setup_commands = [
      install_command,
      'mkdir -p /etc/chef',
      'cd /etc/chef',
    ]

    chef_client_options = {}
    chef_client_options['runlist'] = runlist
    chef_client_options['environment'] = environment if environment

    run_command = []
    chef_client_options.each do |option, value|
      run_command << "--#{option} #{value}"
    end

    run_commands = [
      "chef-client #{run_command.join(' ')}"
    ]

    output = []
    begin
      Net::SSH.start(host, user, ssh_settings) do |ssh|

        info 'Running setup commands'
        setup_commands.each do |command|
          info "  running '#{command}'"
          returned = ssh.exec!(command)
          if returned && returned.is_a?(String)
            if command == install_command
              if returned.include?('Thank you for installing Chef!')
                info "Chef installed successfully"
              else
                lines = returned.split("\n")
                lines.each {|line| error "    #{line}" }
                fail "Install failed" 
              end
            end

            lines = returned.split("\n")
            lines.each {|line| info "    #{line}" }
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
    end

    action_callback output: output
  end
end
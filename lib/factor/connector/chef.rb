require 'factor-connector-api'
require 'net/ssh'
require 'net/scp'
require 'tempfile'
require 'uri'

class Net::SSH::Connection::Session
  class CommandFailed < StandardError
  end

  class CommandExecutionFailed < StandardError
  end

  def exec_sc!(command)
    stdout_data,stderr_data = "",""
    exit_code,exit_signal = nil,nil
    self.open_channel do |channel|
      channel.exec(command) do |_, success|
        raise CommandExecutionFailed, "Command \"#{command}\" was unable to execute" unless success

        channel.on_data do |_,data|
          stdout_data += data
        end

        channel.on_extended_data do |_,_,data|
          stderr_data += data
        end

        channel.on_request("exit-status") do |_,data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |_, data|
          exit_signal = data.read_long
        end
      end
    end
    self.loop

    raise CommandFailed, "Command \"#{command}\" returned exit code #{exit_code}" unless exit_code == 0

    {
      stdout:stdout_data,
      stderr:stderr_data,
      exit_code:exit_code,
      exit_signal:exit_signal
    }
  end
end

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
          returned = ssh.exec_sc!(command)

          returned[:stdout].split("\n").each do |line|
            if returned[:exit_code]==0
              info "    #{line}"
            else
              error "    #{line}"
            end
          end
          returned[:stderr].split("\n").each do |line|
            warn "    #{line}"
          end

          if command == install_command
            if returned[:stdout].include?('Thank you for installing Chef!') && returned[:exit_code]==0
              info "Chef installed successfully"
            else
              fail "Install failed" 
            end
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

          returned = ssh.exec_sc!(command)

          returned[:stdout].split("\n").each do |line|
            if returned[:exit_code]==0
              info "    #{line}"
            else
              error "    #{line}"
            end
          end
          returned[:stderr].split("\n").each do |line|
            warn "    #{line}"
          end

          if returned[:exit_code]==0
            info "Command '#{command}' finished successfully"
          else
            fail "Command '#{command}' failed to run, exit code: #{returned[:exit_code]}" 
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

    action_callback output: 'complete'
  end
end
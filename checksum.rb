require 'digest/md5'
require 'net/ssh'
require 'net/scp'

module Checksum

    def self.checksum(path)
        if File.directory?(path)
            return Checksum.checksumDir(path)
        end
        
        result = `md5sum #{path}`
        result.split(' ')[0] unless result.start_with?('md5sum:')
    end
    
    def self.checksumDir(path)
        contents = Dir.entries(path).select { |d| !d.eql?('.') && !d.eql?('..') }
        
        cathash = ""
        contents.each do |file|
            cathash << Checksum.checksum(File.join(path, file))
        end
        Digest::MD5.hexdigest(cathash)
    end
    
    class RemoteChecksum
        @host = nil
        @user = nil
        @password = nil
        
        def initialize(host, user, password = nil)
            @host = host
            @user = user
            @password = password
        end
    
        def checksum(path)
            Net::SSH.start(@host, @user) do |ssh|
                checksum(ssh, path)
                ssh.close
            end
        end
        
        def checksumWithPassword(path)
            Net::SSH.start(@host, @user, :password => @password) do |ssh|
                checksum(ssh, path)
                ssh.close
            end
        end
    
        def checksum(ssh, path)
              if isDir(ssh, path)
                return checksumDir(ssh, path)
              end

            getChecksum(ssh, path)
        end
        
        def checksumDir(ssh, path)
            contents = getDirectoryContents(ssh, path)

            cathash = ""
            contents.each do |file|
                cathash << checksum(ssh, File.join(path, file))
            end
            Digest::MD5.hexdigest(cathash)
        end
             
        def isDir(ssh, path)
            result = sshExec(ssh, "test -d #{path}")
            result[2] == 0
        end
        
        def getChecksum(ssh, path)
            result = sshExec(ssh, "/opt/bin/md5sum #{path}")
            result[0].split(' ')[0] unless result[2] != 0
        end
        
        def getDirectoryContents(ssh, path)
            result = sshExec(ssh, "ls -1 #{path}")
            result[0].split("\n") unless result[2] != 0
        end
        
        def sshExec(ssh, command)
            stdout_data = ""
            stderr_data = ""
            exit_code = nil
            ssh.open_channel do |channel|
                channel.exec(command) do |ch, success|
                    unless success
                        return nil
                    end
                    channel.on_data do |ch,data|
                        stdout_data+=data
                    end
                    channel.on_extended_data do |ch,type,data|
                        stderr_data+=data
                    end
                    channel.on_request("exit-status") do |ch,data|
                        exit_code = data.read_long
                    end
                end
            end
            ssh.loop
            [stdout_data, stderr_data, exit_code]
        end
    end
end
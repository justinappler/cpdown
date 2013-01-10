require 'net/ssh'
require 'net/scp'

class SshUtils
    @ssh = nil
    
    def self.start(host, user)
        Net::SSH.start(host, user) do |ssh|
            return SshUtils.new(ssh)
        end
    end  

    def close
        @ssh.close
    end
    
    def isDirectory(path)
        result = sshExec("test -d \"#{path}\"")
        result[2] == 0
    end
    
    def checksum(path)
        result = sshExec("/opt/bin/md5sum \"#{path}\"")
        result[0].split(' ')[0] unless result[2] != 0
    end
    
    def getDirectoryContents(path)
        result = sshExec("ls -1 \"#{path}\"")
        result[0].split("\n") unless result[2] != 0
    end
    
    def pathExists?(path)
        result = sshExec("test -e \"#{path}\"")
        result[2] == 0
    end
    
    def createPath(path)
        result = sshExec("mkdir -p \"#{path}\"")
        result[2] == 0
    end
    
    def copy(localPath, remotePath)
        $log.info(" -- Copying #{localPath} to #{remotePath}")
        @ssh.scp.upload!(localPath, remotePath, :recursive => true) do |ch, name, sent, total|
            print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
        end
        true
    end
    
    private 
    
    def initialize(ssh)
        @ssh = ssh
    end
    
    def sshExec(command)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        @ssh.open_channel do |channel|
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
        @ssh.loop
        puts "Exit #{exit_code} for #{command}"
        puts "  Err: #{stderr_data}" if exit_code != 0
        [stdout_data, stderr_data, exit_code]
    end
end
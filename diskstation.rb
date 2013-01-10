require 'net/ssh'
load 'checksum.rb'
load 'sshutils.rb'

class Diskstation
    DS1_ROOT = "/volume1/Diskstation/Videos/"
    DS2_ROOT = "/volume2/Diskstation 2/Videos/"
    MOVIE_ROOT = DS1_ROOT + "Movies/"
    TV_ROOT = DS2_ROOT + "TV/"
    
    @host = nil
    @user = nil
    
    def initialize(host, user) 
        @host = host
        @user = user
    end
    
    def copy(filename, path, fileinfo)
        if fileinfo.type == FNParse::EPISODE
            copyEpisode(filename, path, fileinfo)
        else
            false
        end
    end
    
    def copyEpisode(filename, path, fileinfo)
        $log.info("Copying Episode \'#{filename}\'")
        remotePath = getEpisodeRemotePath(filename, fileinfo)
        $log.info(" -- Copying to #{remotePath}")
        copyFile(path, remotePath, filename)
    end
    
    def getEpisodeRemotePath(filename, fileinfo)
        "#{TV_ROOT}#{fileinfo.title}/Season #{fileinfo.season.to_s}/"
    end
    
    def copyFile(localPath, remotePath, filename)
        ssh = SshUtils.start(@host, @user)
        
        # If the remote path does not exist
        puts "Path Exists? #{ssh.pathExists?(remotePath)} -> #{remotePath}"
        if not ssh.pathExists?(remotePath)
            $log.info("Created Path: #{remotePath}") unless !ssh.createPath(remotePath)
        end
        
        # Checksum the local path
        localChecksum = Checksum::checksum(localPath)
        $log.info(" -- Local Checksum: #{localChecksum}") unless !localChecksum

        # Checksum the remote path
        rcs = Checksum::SshChecksum.new(ssh)
        remoteChecksum = rcs.checksum(remotePath)
        $log.info(" -- Remote Checksum: #{remoteChecksum}") unless !remoteChecksum
        
        # If they match, we're done, just log it!
        if localChecksum == remoteChecksum
            $log.warn("Tried to copy existing file with matching checksum: #{localPath}")
            return true
        end
        
        ssh.copy(localPath, remotePath)
        
        ssh.close
        true
    end

end
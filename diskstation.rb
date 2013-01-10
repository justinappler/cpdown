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
        elsif fileinfo.type == FNParse::DATE_EPISODE
            copyDateEpisode(filename, path, fileinfo)
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
    
    def copyDateEpisode(filename, path, fileinfo)
        $log.info("Copying Date Episode \'#{filename}\'")
        remotePath = getDateEpisodeRemotePath(filename, fileinfo)
        $log.info(" -- Copying to #{remotePath}")
        copyFile(path, remotePath, filename)
    end
    
    def getDateEpisodeRemotePath(filename, fileinfo)
        "#{TV_ROOT}#{fileinfo.title}/"
    end
    
    def copyFile(localPath, remotePath, filename)
        ssh = SshUtils.start(@host, @user)
        
        # If the remote path does not exist
        if not ssh.pathExists?(remotePath)
            $log.info(" -- Created Path: #{remotePath}") unless !ssh.createPath(remotePath)
            ssh.chmod(remotePath, "777")
        end
        
        # Checksum the local path
        localChecksum = Checksum::checksum(localPath)
        $log.info(" -- Local Checksum: #{localChecksum}") unless !localChecksum

        # Checksum the remote path
        rcs = Checksum::SshChecksum.new(ssh)
        remoteChecksum = rcs.checksum(File.join(remotePath, filename))
        $log.info(" -- Remote Checksum: #{remoteChecksum}") unless !remoteChecksum
        
        # If they match, we're done, just log it!
        if localChecksum.eql?(remoteChecksum)
            $log.warn(" -- Tried to copy existing file with matching checksum: #{localPath}")
            return true
        end
        
        copyResult = ssh.copy(localPath, remotePath)
        
        ssh.close
        copyResult
    end

end
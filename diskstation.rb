require 'net/ssh'
load 'checksum.rb'

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
        $log.info("Copying file \'#{filename}\'")

        if fileinfo.type == FNParse::EPISODE
            copyEpisode(filename, path, fileinfo, cksum)
        else
            false
        end
    end
    
    def copyEpisode(file, path, fileinfo)
        remoteFilename = getEpisodeRemoteFilename(file, fileinfo)
        $log.info(" -- Copying to #{remoteFilename}")
        copyFile(path, remoteFilename)
    end
    
    def getEpisodeRemoteFilename(filename, fileinfo)
        "#{TV_ROOT}#{fileinfo.title}/Season #{fileinfo.season.to_s}/#{filename}"
    end
    
    def copyFile(localPath, remotePath)
        # If the remote path does not exist
        #    Create the remote path
        
        # Checksum the local path
        localChecksum = localChecksum(localPath)
        $log.info(" -- Local Checksum: #{localChecksum}") unless !localChecksum

        # Checksum the remote path
        rcs = Checksum::RemoteChecksum.new(@host, @user)
        remoteChecksum = rcs.checksum(remotePath)
        
        # If they match, we're done, just log it!
        if localChecksum == remoteChecksum do
            $log.warn("Tried to copy existing file with matching checksum: #{localPath}")
            return true
        end
        
    end

end
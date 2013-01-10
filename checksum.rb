require 'digest/md5'
load 'sshutils.rb'

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
            sshutil = SshUtils.start(@host, @user)
            cksum = _checksum(sshutil, path)
            sshutil.close
            cksum
        end
    
        def _checksum(sshutil, path)
            sshutil.isDirectory(path) ? checksumDir(sshutil, path) : sshutil.checksum(path)
        end
        
        def checksumDir(sshutil, path)
            contents = sshutil.getDirectoryContents(path)

            cathash = ""
            contents.each do |file|
                cathash << _checksum(sshutil, File.join(path, file))
            end
            Digest::MD5.hexdigest(cathash)
        end
    end
end
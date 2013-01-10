require 'digest/md5'

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
    
    class SshChecksum
        @ssh = nil
        
        def initialize(ssh)
            @ssh = ssh
        end
    
        def checksum(path)
            @ssh.isDirectory(path) ? checksumDir(path) : @ssh.checksum(path)
        end
        
        private
        
        def checksumDir(path)
            contents = @ssh.getDirectoryContents(path)

            cathash = ""
            contents.each do |file|
                cathash << checksum(File.join(path, file))
            end
            
            Digest::MD5.hexdigest(cathash)
        end
    end
end
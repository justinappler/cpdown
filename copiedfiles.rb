class CopiedFiles
    @copied = nil
    @copiedFilename = nil
    
    def initialize(filename)
        @copiedFilename = filename
        
        begin
            @copied = IO.readlines(@copiedFilename).collect { |line| line.chomp }
            $log.info('Opened Copied File list, Size: ' + @copied.length.to_s)
        rescue
            @copied = Array.new()
            $log.warn('No Copied File list found, starting empty')
        end
	end
    
    def add(file)
        $log.info('Added ' + file + ' to copied list')
        @copied.push file
        save
    end
    
    def exists(file)
        @copied.include? file
    end
    
    def save
        begin
            f = File.open(@copiedFilename, 'w')
            @copied.each { |line| f.write(line + "\n") }
            f.close
            $log.info('Saved the copied file list')
        rescue
            $log.error('Couldn\'t save the Copied Files list')
        end
    end
end

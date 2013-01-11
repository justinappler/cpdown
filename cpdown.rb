require 'logger'

load 'copiedfiles.rb'
load 'fnparse.rb'
load 'diskstation.rb'
load 'config.rb'

# Logging
$log = Logger.new(LOGFILE, File::WRONLY | File::APPEND)
$log.level = Logger::INFO

begin 
    # Get a lock
    lockfile = File.open(LOCKFILE, 'w')
    lockfile.flock(File::LOCK_EX)

    $log.info("Starting cpdown (lock acquired)")

    # CopiedFile list
    copied = CopiedFiles.new(COPIED_FILE)

    # Diskstation
    ds = Diskstation.new(DS_HOST, DS_USER)

    # Get all torrents in the seeding directory (completed torrents)
    new = Dir.entries(TORRENT_DIR).select { |f| 
        !f.eql?('.') && !f.eql?('..') && !copied.exists(f) 
    }

    # for each file, parse the name and copy it to the diskstation
    new.each do |file|
        fileinfo = FNParse::parse(file)
        copied.add(file) unless !ds.copy(file, File.join(TORRENT_DIR, file), fileinfo)
    end
rescue
    raise
ensure
    lockfile.flock(File::LOCK_UN) unless lockfile.nil?
    lockfile.close unless lockfile.nil?
end

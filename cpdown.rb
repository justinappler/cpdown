require 'logger'

load 'copiedfiles.rb'
load 'fnparse.rb'
load 'diskstation.rb'

# Constants
COPIED_FILE = "copied"
LOGFILE = "log"
RTORRENT_DIR = "/media/sde1/home/jappler/private/rtorrent/"
#TORRENT_DIR = RTORRENT_DIR + "data/seed/"
TORRENT_DIR = "./torrents/"

# Diskstation Directories
DS_HOST = "jappler.synology.me"
DS_USER = "feral"

# Logging
$log = Logger.new(LOGFILE, File::WRONLY | File::APPEND)
$log.level = Logger::INFO

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


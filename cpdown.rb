require 'logger'
require 'copiedfiles'
require 'fnparse'

# Constants
COPIED_FILE = "copied"
LOGFILE = "log"
RTORRENT_DIR = "/media/sde1/home/jappler/private/rtorrent/"
TORRENT_DIR = RTORRENT_DIR + "data/seed/"

# Diskstation Directories
DS_HOST = "jappler.synology.me"
DS_USER = "feral"
DS1_ROOT = "/volume1/Diskstation/Videos/"
DS2_ROOT = "/volume2/Diskstation 2/Videos/"
MOVIE_ROOT = DS1_ROOT + "Movies/"
TV_ROOT = DS2_ROOT + "TV/"

# Logging
log = Logger.new(LOGFILE, File::WRONLY | File::APPEND)
log.level = Logger::INFO

# CopiedFile list
copied = CopiedFiles.new(COPIED_FILE, log)

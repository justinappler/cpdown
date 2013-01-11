module FNParse
    UNKNOWN = 0
    EPISODE = 1
    DATE_EPISODE = 2 # TV Shows without Ep numbers (e.g. The Daily Show)
    MOVIE = 3
    
    @@EP_REG_1 = /(.+)\.S([0-9]{1,2})E([0-9]{1,2})/
    @@EP_REG_2 = /(.+)\.([0-9]{1,2})x([0-9]{1,2})/
    
    @@DATE_EP_REG_1 = /(.+)\.201[0-9]{1}\.[0-9]{1,2}\.[0-9]{1,2}/
    
    @@MOVIE_REG_1 = /(.*)[\. ](201[0-9]{1})[\. ](DVDRip|BDRip|HDRip)/

    def self.parse(filename)
        $log.info('Parsing filename: ' + filename.to_s)
        isEpisode(filename) || isDateEpisode(filename) || isMovie(filename) || isUnknown(filename)
    end
    
    def self.isEpisode(filename)
        result = filename.scan(@@EP_REG_1)
        if (result.empty?)
            result = filename.scan(@@EP_REG_2)
        end
        
        return episodeResult(result[0][0], result[0][1], result[0][2]) unless result.empty?
    end
    
    def self.episodeResult(title, season, episode)
        r = FNParseResult.new(
            FNParse::EPISODE,
            title.gsub(/[\._]/, ' ').gsub(/^[a-z]|\s[a-z]/) { |a| a.upcase }.chomp,
            season.to_i,
            episode.to_i
        )
        $log.info("TV Episode Parsed: #{r.title}, S#{r.season.to_s}, E#{r.episode.to_s}")
        r
    end
    
    def self.isDateEpisode(filename)
        if (not (result = filename.scan(@@DATE_EP_REG_1)).empty?)
            return dateEpisodeResult(result[0][0])
        end
    end
    
    def self.dateEpisodeResult(title)
        r = FNParseResult.new(
            FNParse::DATE_EPISODE,
            title.gsub(/[\._]/, ' ').gsub(/^[a-z]|\s[a-z]/) { |a| a.upcase }.chomp,
            nil,
            nil
        )
        $log.info("Date Episode Parsed: #{r.title}")
        r
    end
    
    def self.isMovie(filename)
        if (not (result = filename.scan(@@MOVIE_REG_1)).empty?)
            return movieResult(result[0][0])
        end
    end
    
    def self.movieResult(title)
        r = FNParseResult.new(
            FNParse::MOVIE,
            title.gsub(/[\._]/, ' ').gsub(/^[a-z]|\s[a-z]/) { |a| a.upcase }.chomp,
            nil,
            nil
        )
        $log.info("Movie Parsed: #{r.title}")
        r
    end
    
    def self.isUnknown(filename)
        $log.warn('Unparseable file type: ' + filename)
        FNParseResult.new(FNParse::UNKNOWN, nil, nil, nil)
    end

    class FNParseResult
        attr_accessor :type
        @type = FNParse::UNKNOWN
        
        attr_accessor :title
        @title = nil
        
        attr_accessor :season
        @season = 0
        
        attr_accessor :episode
        @episode = 0
        
        def initialize(type, title, season, episode)
            @type = type
            @title = title
            @season = season
            @episode = episode
        end
    end
end
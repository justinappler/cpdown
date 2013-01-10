module FNParse
    UNKNOWN = 0
    EPISODE = 1
    DATE_EPISODE = 2 # TV Shows without Ep numbers (e.g. The Daily Show)
    MOVIE = 3
    
    @@EP_REG_1 = /(.+)\.S([0-9]{1,2})E([0-9]{1,2})/
    @@EP_REG_2 = /(.+)\.([0-9]{1,2})x([0-9]{1,2})/

    def self.parse(filename)
        $log.info('Parsing filename: ' + filename.to_s)
        isEpisode(filename) || isDateEpisode(filename) || isMovie(filename) || isUnknown(filename)
    end
    
    def self.isEpisode(filename)
        if (not (result = filename.scan(@@EP_REG_1)).empty?)
            return episodeResult(result[0][0], result[0][1], result[0][2])
        end
        
        if (not (result = filename.scan(@@EP_REG_2)).empty?)
            return episodeResult(result[0][0], result[0][1], result[0][2])
        end
            
        return false
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
        false
    end
    
    def self.isMovie(filename)
        false
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
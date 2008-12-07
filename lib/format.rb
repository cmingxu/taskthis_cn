module Format
  
  EMAIL = /^[_a-z0-9\+\.\-]+\@[_a-z0-9\-]+\.[_a-z0-9\.\-]+$/i    
  PASSWORD = /^[\_a-zA-Z0-9\.\-]+$/

  BADGE_PATTERN = /\A([\w]*):([\w|\W|\s|.]*)/i

  # Dates
  LONG_DATE = "%m/%d/%Y %H:%M"
  SHORT_DATE = "%b %d"
  
  def self.format_date( date, mask=nil )
     mask = mask || LONG_DATE
     date.strftime( mask ) unless date.nil?
  end

  # Turns a title into a name with no spaces in it. it will 
  # replace the spaces with dashes '-'
  #
  #  src:  This is a test Title Baby!
  #
  # out:  this-is-a-test-title-baby
  #
  def self.sanitize_name( title )
    name = title.downcase.clone
    name.gsub!( /[\?\.\\\/ ]/, '-' )
    name.gsub( /[^a-z0-9\-\_]/, '' )
  end

end
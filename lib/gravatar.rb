require 'digest/md5'
require 'cgi'


def gravatar_url( email, default='/images/no-avatar.jpg', size=80, rating='X' )
   # Gravatar wants an MD5 hash of the email address...
   email_hash = Digest::MD5.hexdigest( email )
   default_image = CGI::escape( default )
   "http://www.gravatar.com/avatar.php?gravatar_id=#{email_hash}&size=#{size}&rating=#{rating}&default=#{default_image}"
end

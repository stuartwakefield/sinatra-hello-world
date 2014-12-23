class User

  def initialize(username)
    @username = username
  end

  def to_hash
    uri = "/users/#{ @username }"
    self_link = { rel: 'self', href: uri }
    delete_link = { rel: 'delete', href: uri, method: 'DELETE' }
    { username: @username, link: [ self_link, delete_link ] }
  end

end

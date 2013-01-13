module Tomb
  class UserList
    User = Struct.new(:username, :api_token)

    attr_reader :store

    def initialize(filename)
      @store = YAML::Store.new(filename)
    end

    def add_user(username)
      return if find_by_username(username)
      user = User.new(username, generate_token)
      store.transaction do
        store['users'] ||= []
        store['users'] << user
      end
    end

    def api_token(username)
      find_by_username(username).api_token
    end

    def find_by_username(username)
      users.find { |u| u.username == username }
    end

    def find_by_api_token(api_token)
      users.find { |u| u.api_token == api_token }
    end

    def users
      store.transaction { store['users'] } || []
    end

    def generate_token
      'foobar'
    end
  end
end

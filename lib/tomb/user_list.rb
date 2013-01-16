module Tomb
  class UserList
    User = Struct.new(:username, :api_token)

    include Enumerable

    extend Forwardable
    def_delegators :users, :size, :empty?, :each

    def initialize(store_path)
      @store = YAML::Store.new(store_path)
    end

    def users
      store.transaction { store.fetch('users', []) }
    end

    def push(username)
      return self if find_by_username(username)
      store.transaction do
        (store['users'] ||= []) << User.new(username, SecureRandom.hex)
      end
      self
    end
    alias_method :<<, :push

    def find_by_username(username)
      users.find { |u| u.username == username }
    end

    def find_by_api_token(api_token)
      users.find { |u| u.api_token == api_token }
    end

    private

    def store
      @store
    end
  end
end

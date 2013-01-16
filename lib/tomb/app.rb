module Tomb
  class App < Sinatra::Base
    set :haml, format: :html5
    set :scss, style: :compressed
    set :root, File.expand_path(File.join('..', '..', '..'), __FILE__)

    configure :production, :development do
      enable :logging
      enable :sessions
    end

    configure :production do
      disable :raise_errors
      disable :show_exceptions
    end

    register Sinatra::Auth::Github

    helpers do
      def store
        @store ||= Store.new(settings.artifacts)
      end

      def user_list
        @user_list ||= UserList.new(settings.user_list)
      end

      def authenticate_and_register
        github_organization_authenticate!(settings.github_options.fetch(:organization))
        user_list << github_user.login
      end

      def authenticate_by_token
        user_list.find_by_api_token(params['token']) or halt 403
      end

      def current_user
        @current_user ||= user_list.find_by_username(github_user.login)
      end
    end

    set(:request_method) do |*values|
      condition do
        current_method = request.request_method.downcase.to_sym
        current_method == values || values.include?(current_method)
      end
    end

    before /^\/artifacts/, request_method: :get do
      authenticate_and_register
    end

    before '/artifacts', request_method: :post do
      authenticate_by_token
    end

    get '/styles.css' do
      headers 'Content-Type' => 'text/css; charset=utf-8'
      scss :styles
    end

    get '/lib.js' do
      headers 'Content-Type' => 'text/javascript'
      coffee :lib
    end

    get '/' do
      haml :index
    end

    # When loading a static file fails because the file requested
    # is a directory, try redirecting to an underlying index.html
    # file.
    error Errno::EISDIR do
      redirect to(File.join(request.path, 'index.html'))
    end

    error Errno::ENOENT do
      halt 404
    end

    not_found do
      '404 File not found'
    end

    # Accepts a single gzipped archive containing artifacts files.
    #
    # Params:
    #
    #   build_id
    #   archive
    #   archive_filename
    #
    post '/artifacts' do
      store.add_archive params
    end

    # Browse through artifacts
    get '/artifacts' do
      haml :artifacts
    end

    # Browse static build artifact files
    get '/artifacts/*' do
      path = params[:splat].first
      content_type 'text/css'        if path =~ /css$/
      content_type 'text/javascript' if path =~ /js$/
      store.read_file(File.join(*params[:splat]))
    end

    get '/logout' do
      logout!
      redirect to('/')
    end
  end
end

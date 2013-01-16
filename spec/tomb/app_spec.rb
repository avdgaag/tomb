require 'rack/test'

describe Tomb::App do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  after { Warden.test_reset! }

  def app
    described_class.set :environment, :test
    described_class.set :github_options, { organization: 'foobar' }
    described_class.set :user_list, File.expand_path('../../../tmp/users.yml', __FILE__)
    described_class.set :root,      File.expand_path('../../..',               __FILE__)
    described_class.set :artifacts, File.expand_path('../../../tmp/artifacts', __FILE__)
    described_class.new
  end

  after do
    File.unlink described_class.user_list if File.exist? described_class.user_list
  end

  describe 'GET /' do
    before     { get '/' }
    subject    { last_response }
    it         { should be_ok }
    its(:body) { should include('Log in') }
  end

  # context 'when logged in via Github' do
  #   let(:user) { double('user', login: 'john', organization_member?: true) }
  #   before     { login_as user }

  #   describe 'GET /artifacts' do
  #     before     { get '/artifacts' }
  #     subject    { last_response }
  #     it         { should be_ok }
  #     its(:body) { should include('Log out') }
  #   end
  # end

  context 'when not logged in' do
    describe 'GET /artifacts' do
      before     { get '/artifacts' }
      subject    { last_response }
      it         { should be_redirect }
    end
  end
end

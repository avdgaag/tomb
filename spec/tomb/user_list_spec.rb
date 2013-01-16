describe Tomb::UserList do
  def fixture(filename)
    source = File.join('spec', 'fixtures', filename)
    return source unless File.exist? source
    dest = File.join('spec', 'fixtures', filename + '2')
    FileUtils.cp source, dest
    dest
  end

  after do
    FileUtils.rm Dir.glob('spec/fixtures/*.yml2')
    FileUtils.rm 'spec/fixtures/users_none.yml' if File.exist?('spec/fixtures/users_none.yml' )
  end

  context 'when empty' do
    subject    { described_class.new(fixture('users_none.yml')) }
    it         { should be_empty }
    it         { should have(0).users }
    its(:size) { should eql(0) }
  end

  context 'when there is a user' do
    subject    { described_class.new(fixture('users_one.yml')) }
    it         { should_not be_empty }
    its(:size) { should eql(1) }
    it         { should have(1).users }

    it 'does not add the same user again' do
      expect { subject << 'John' }.to_not change { subject.count }
    end

    it 'does add a new user' do
      expect { subject << 'Graham' }.to change { subject.count }.by(1)
    end

    it 'finds users by username' do
      expect(subject.find_by_username('John')).to_not be_nil
    end

    it 'finds users by API token' do
      expect(subject.find_by_api_token('foobar')).to_not be_nil
    end
  end

  describe 'records' do
    subject         { described_class.new(fixture('users_one.yml')).first }
    its(:username)  { should eql('John') }
    its(:api_token) { should eql('foobar') }
  end

  describe 'tokens' do
    subject { described_class.new(fixture('users_none.yml')) }

    context 'for new users' do
      it 'generates a random API token' do
        subject << 'John'
        expect(subject.first.api_token).to_not be_nil
      end
    end

    context 'for existing users' do
      it 'does not change the API token' do
        subject << 'John'
        expect { subject << 'John' }.to_not change { subject.first.api_token }
      end
    end
  end
end

describe Tomb::Archive do
  context 'given a bad file' do
    subject(:archive) { described_class.new(File.join('spec', 'fixtures', 'example.txt')) }

    it 'raises an error' do
      expect { archive.extract_to(path.join('coverage')) }.to raise_error
    end
  end

  context 'given a good file' do
    let(:path) { Pathname.new(File.join('tmp', 'archive')) }

    before do
      described_class.new(File.join('spec', 'fixtures', 'archive.tgz')).extract_to(path)
    end

    after do
      FileUtils.rmdir(path)
    end

    it 'should create directories' do
      expect(File.directory?(path.join('coverage'))).to be_true
    end

    it 'should create files' do
      expect(File.file?(path.join('coverage', 'index.html'))).to be_true
    end
  end
end

describe Tomb::Store do
  describe '#add_archive' do
    subject(:store) { described_class.new('spec/fixtures/builds') }

    it 'extracts an archive into the target directory' do
      file = File.open('spec/fixtures/example.txt')
      dummy = double
      dummy.should_receive(:extract_to).with(Pathname('spec/fixtures/builds/1'))
      Tomb::Archive.should_receive(:new).with(file).and_return(dummy)
      store.add_archive 'archive_filename' => 'foo.tgz', 'archive' => { tempfile: file }, 'build_id' => '1'
    end

    describe 'arguments' do
      it 'requires a build ID' do
        expect {
          store.add_archive 'archive_filename' => 'foo.tgz', 'archive' => { tempfile: 'foo' }
        }.to raise_error(KeyError)
      end

      it 'requires a tempfile' do
        expect {
          store.add_archive 'build_id' => '1', 'archive_filename' => 'foo'
        }.to raise_error(KeyError)
      end

      it 'requires an archive filename' do
        expect {
          store.add_archive 'build_id' => '1', 'archive' => { tempfile: 'foo' }
        }.to raise_error(KeyError)
      end
    end
  end

  describe '#builds' do
    subject(:store) { described_class.new('spec/fixtures/builds').builds }
    it { should eql({ '23' => ['coverage'] }) }
  end

  describe '#read_file' do
    subject(:store) { described_class.new('spec/fixtures') }

    context 'when it exists' do
      it 'returns the file contents' do
        expect(store.read_file('example.txt')).to eql("foobar\n")
      end
    end

    context 'when it does not exist' do
      it 'raises an error' do
        expect { store.read_file('bla') }.to raise_error(Errno::ENOENT)
      end
    end
  end
end

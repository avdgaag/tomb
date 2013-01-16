module Tomb
  class Archive
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def extract_to(path)
      path = Pathname(path)
      each_file do |entry|
        output_path = path.join(entry.full_name)
        FileUtils.mkdir_p(File.dirname(output_path)) unless File.directory?(File.dirname(output_path))
        File.open(output_path, 'wb') do |f|
          f.print entry.read
        end
      end
    end

    private

    def each_file(&block)
      io = Zlib::GzipReader.open(file)
      Gem::Package::TarReader.new(io) do |tar|
        tar.each do |entry|
          yield entry if entry.file?
        end
      end
    end
  end
end

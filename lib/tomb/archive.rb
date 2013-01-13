module Tomb
  class Archive
    include Enumerable
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def each(&block)
      io = Zlib::GzipReader.open(file)
      Gem::Package::TarReader.new(io) do |tar|
        tar.each(&block)
      end
    end

    def extract_to(path)
      path = Pathname(path)
      each do |entry|
        output_path = path.join(entry.full_name)
        if entry.directory?
          FileUtils.mkdir_p(output_path) unless File.directory?(File.dirname(output_path))
        else
          FileUtils.mkdir_p(File.dirname(output_path)) unless File.directory?(File.dirname(output_path))
          File.open(output_path, 'wb') do |f|
            f.print entry.read
          end
        end
      end
    end
  end
end

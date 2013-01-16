module Tomb
  class Store
    attr_reader :root_path

    def initialize(root_path)
      @root_path = Pathname(root_path)
    end

    def add_archive(options = {})
      build_id = options.fetch 'build_id'
      file     = options.fetch('archive', {}).fetch(:tempfile)
      filename = options.fetch 'archive_filename'
      output_path = root_path.join(build_id)
      Archive.new(file).extract_to(output_path)
    end

    def read_file(path)
      File.read(root_path.join(path))
    end

    def builds
      Hash.new { |hash, key| hash[key] = [] }.tap do |artifacts|
        Dir[root_path.join('*', '*')].inject(artifacts) do |grouped, path|
          path = Pathname(path).relative_path_from(root_path).to_s
          build, rest = path.split('/', 2)
          grouped[build] << rest
          grouped
        end
      end
    end
  end
end

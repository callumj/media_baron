module MediaMogul
  module Tools

    def self.find_executable(exec)

      # props to mislav @ http://stackoverflow.com/a/5471032/497646
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = "#{path}#{File::SEPARATOR}#{exec}#{ext}"
          return exe if File.executable? exe
        }
      end
      return nil

    end

  end
end
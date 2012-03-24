class Packr
  module FileSystem
    
    def self.bundle(options)
      sources = options.keys.grep(Array).first
      output  = options[sources]
      header  = options[:header] ? options[:header] + "\n" : ""
      
      sources = sources.map { |s| File.expand_path(s) }
      output  = File.expand_path(output)
      
      code    = ''
      offsets = {}
      
      sources.each do |source|
        offsets[source] = code.size
        code << File.read(source) + "\n"
      end
      
      packed = Packr.pack(code,
        :shrink_vars  => options[:shrink_vars],
        :private      => options[:private],
        :source_files => offsets,
        :output_file  => output,
        :line_offset  => header.scan(/\r\n|\r|\n/).size
      )
      source_map = packed.source_map
      packed = header + packed
      
      FileUtils.mkdir_p(File.dirname(output))
      File.open(output, 'w') { |f| f.write(packed) }
      File.open(source_map.filename, 'w') { |f| f.write(source_map.to_s) }
    end
    
  end
end
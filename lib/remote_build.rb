  module RemoteBuild    
=begin    
    def run(result, &progress_block)
      orig_filename = "%s.rb" % base.class_name.underscore
      filename, i = orig_filename.dup, 0
      loop do 
        break unless File.exist? filename
        filename = "%s.%d.rb" % [orig_filename, i+=1]
      end
    
      File.open(filename, "w") do |f|
        f << Curl::Easy.http_post('http://apigen.info') {
           [@tests, ['http://localhost:8983/solr']]
          } # serialize somehow
      end
        
      begin
        require filename
        # thor invoke :loc filename
      rescue => e
        puts "Remote code '#{filename}' not valid: \n#{e}"
      end
    end
=end
      def run(result, &progress_blk)
        unless @tests.first.class.name.match /^BuildCase$/
          safe_save remote(result)
        end
        super
      end
      
      def remote(tests, *args)
        tests
      end
      def safe_save(*args)
        puts args
      end  
 end
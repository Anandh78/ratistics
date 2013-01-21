require 'code_statistics'

desc "Report code statistics"
task :loc do
  
  STATS_DIRECTORIES = [
    %w(Libraries lib/),
  ].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

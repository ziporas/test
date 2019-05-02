# run script 
# for single repository
# rails r unshallow_script.rb  <namespace> <project_name>
# for all repositories
# rails r unshallow_script.rb all

# Log: production.log
Rails.logger.info  '[unshallow_all_repositories]: start unshallow repositories'
p '[unshallow_all_repositories]: start unshallow repositories'
projects = nil
if ARGV[0] == "all"
  projects = Project.all
  Rails.logger.info '[unshallow_all_repositories]: running for all repositories'
  p '[unshallow_all_repositories]: running for all repositories'
else 
  namespace = ARGV[0]
  project_name = ARGV[1]
  projects =  Namespace.where(:name => namespace).first.projects.where(:name => project_name)
  Rails.logger.info '[unshallow_all_repositories]: running for single repository'
  p '[unshallow_all_repositories]: running for single repository'
end
start_time = Time.now
projects.each do |project|   
    begin 
      cmd = %W(#{Gitlab.config.git.bin_path} --git-dir=#{project.repository.path} --work-tree=#{project.repository.path} fetch --unshallow #{FlowPortal.config.sample.remote_import_url})
      stdin, stdout, stderr = Open3.popen3(*cmd)
      result = stderr.gets(nil)
      Rails.logger.info("[unshallow_all_repositories]: update project - id: #{project.id}, name: #{project.name} result: #{result}")
      p "[unshallow_all_repositories]: update project - id: #{project.id}, name: #{project.name} result: #{result}"
      project.satellite.repo.git.native(:fetch, {:unshallow =>  true})

      Rails.logger.info("[unshallow_all_repositories]: update project  id: #{project.id}- Duration: #{Time.now - start_time} seconds")
      p "[unshallow_all_repositories]: update project  id: #{project.id}- Duration: #{Time.now - start_time} seconds"
    rescue Exception => ex 
      Rails.logger.error("[unshallow_all_repositories]: error in update project - id: #{project.id}, name: #{project.name}")
      p "[unshallow_all_repositories]: error in update project - id: #{project.id}, name: #{project.name}"
      Rails.logger.error(ex.message)
      p ex.message
    end      
end


Rails.logger.info("[unshallow_all_repositories]: update all repositories - Duration: #{Time.now - start_time} seconds")
p "[unshallow_all_repositories]: update all repositories - Duration: #{Time.now - start_time} seconds"

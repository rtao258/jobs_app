require "sinatra/base"
require "open3"
require "nokogiri"

class App < Sinatra::Base
  set :erb, :escape_html => true

  def title
    ENV['USER'].capitalize + "'s Jobs"
  end

  get "/" do
    erb:index
  end

  get "/:user" do
    @user = params[:user]
    jobs = []
    owners = []
    output, status = Open3.capture2e("/opt/torque/bin/qstat -f -x")
    output = Nokogiri::XML(output)

    output.css("Job").each do |job|
      job_owner = job.at_css("Job_Owner").content.split("@")[0]
      owners << job_owner
      
      if job_owner == @user
        
        job_name = job.at_css("Job_Name").content
        job_ID = job.at_css("Job_Id").content.split(".")
        mem = nil #job.at_css("resources_used mem").content
        vmem = nil #job.at_css("resources_used vmem").content
        walltime = nil #job.at_css("resources_used walltime").content
            
        queue = job.at_css("queue").content
        server = job.at_css("server").content
        
        error_path = job.at_css("Error_Path").content
        output_path = job.at_css("Output_Path").content
            
        resource_walltime = nil #job.at_css("Resource_List walltime").content
        resource_nodes = nil #job.at_css("Resource_List nodes").content
        resource_mem = nil #job.at_css("Resource_List mem").content
            
        session_ID = nil #job.at_css("session_id").content
        shell_path_list = job.at_css("Shell_Path_List").content
        euser = job.at_css("euser").content
        egroup = job.at_css("egroup").content
            
        jobs << {job_owner: job_owner, job_name: job_name, job_ID: job_ID, mem: mem, vmem: vmem, walltime: walltime, 
        queue: queue, server: server, 
        err_path: error_path, out_path: output_path, 
        res_walltime: resource_walltime, res_nodes: resource_nodes, res_mem: resource_mem, 
        ses_ID: session_ID, shell_path_list: shell_path_list, euser: euser, egroup: egroup}
      end
    end
    
    @output = jobs
    erb:jobs
  end
  
end

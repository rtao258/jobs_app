require "sinatra/base"  # Sinatra
require "open3"         # Commands

# XML
require "nori"
require "nokogiri"
require_relative "xml_tools"

class App < Sinatra::Base
  set :erb, :escape_html => true

  def title
    ENV['USER'].capitalize + "'s Jobs"
  end

  get "/" do
    erb :index
  end
  
  post "/" do
    @user = params[:user]
    redirect url("/#{@user}")
  end

  get "/:user" do
    @user = params[:user]
    output, status = Open3.capture2e("/opt/torque/bin/qstat -f -x")
    output = Nori.new.parse(output)
    all_jobs = output["Data"]["Job"]
    user_jobs = []
    owners = []
    
    all_jobs.each do |job|
      job_owner = job["Job_Owner"].split("@")[0]
      owners << job_owner
      if job_owner == @user
        job_name = job["Job_Name"]
        job_ID = job["Job_Id"].split(".")
        mem = job["resources_used"]["mem"]
        vmem = job["resources_used"]["vmem"]
        walltime = job["resources_used"]["walltime"]
        
        queue = job["queue"]
        server = job["server"]
        
        error_path = job["Error_Path"]
        output_path = job["Output_Path"]
        
        resource_walltime = job["Resource_List"]["walltime"]
        resource_nodes = job["Resource_List"]["nodes"]
        resource_mem = job["Resource_List"]["mem"]
        
        session_ID = job["session_id"]
        shell_path_list = job["Shell_Path_List"]
        euser = job["euser"]
        egroup = job["egroup"]
        
        user_jobs << {job_owner: job_owner, job_name: job_name, job_ID: job_ID, mem: mem, vmem: vmem, walltime: walltime, 
                  queue: queue, server: server, 
                  err_path: error_path, out_path: output_path, 
                  res_walltime: resource_walltime, res_nodes: resource_nodes, res_mem: resource_mem, 
                  ses_ID: session_ID, shell_path_list: shell_path_list, euser: euser, egroup: egroup}

      end
    end
    
    @output = user_jobs
    erb :jobs
  end
  
end

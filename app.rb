require "sinatra/base"
require "open3"
require "nokogiri"

class App < Sinatra::Base
  set :erb, :escape_html => true

  def title
    ENV['USER'].capitalize + "'s Jobs"
  end

  get "/" do
    erb :index
  end

  get "/:user" do
    @user = params[:user]
    jobs = []
    output, status = Open3.capture2e("/opt/torque/bin/qstat -f -x")
    output = Nokogiri::XML(output)
    output.xpath("//Job").each do |job|
      job_owner = job.xpath(//"Job_Owner")[0].content.split("@")[0]
      if job_owner == @user
        job_name = job.xpath("//Job_Name")[0].content
        job_ID = job.xpath("//Job_Id")[0].content.split(".")[0]
        mem = job.xpath("//resources_used")[0].xpath("//mem")[0].content
        vmem = job.xpath("//resources_used")[0].xpath("//vmem")[0].content
        walltime = job.xpath("//resources_used")[0].xpath("//walltime")[0].content
        
        queue = job.xpath("//queue")[0].content
        server = job.xpath("//server")[0].content
        
        error_path = job.xpath("//Error_Path")[0].content
        output_path = job.xpath("//Output_Path")[0].content
        
        resource_walltime = job.xpath("//Resource_List")[0].xpath("//walltime")[0].content
        resource_nodes = job.xpath("//Resource_List")[0].xpath("//nodes")[0].content
        resource_mem = job.xpath("//Resource_List")[0].xpath("//mem")[0].content
        
        sesssion_ID = job.xpath("//session_id")[0].content
        shell_path_list = job.xpath("//Shell_Path_List")[0].content
        euser = job.xpath("//euser")[0].content
        egroup = job.xpath("//egroup")[0].content
        
        
        jobs.push({job_owner: job_owner, job_name: job_name, job_ID: job_ID, mem: mem, vmem: vmem, walltime: walltime, queue: queue, server: server, err_path: error_path, out_path: output_path, res_walltime: resource_walltime, res_nodes: resource_nodes, res_mem: resource_mem, ses_ID: session_id, shell_path_list: shell_path_list, euser: euser, egroup: egroup})
        
        
      end
    end
    @output = jobs
    erb :jobs
  end
  
end

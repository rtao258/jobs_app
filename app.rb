require "sinatra/base"
require "open3"
require "nokogiri"

class App < Sinatra::Base
  set :erb, :escape_html => true

  def title
    "Jobs App"
  end

  get "/" do
    erb :index
  end
  
  post "/" do
    user = params[:user]
    redirect "/#{user}"
  end

  get "/:user" do
    @user = params[:user]
    jobs = []
    output, status = Open3.capture2e("/opt/torque/bin/qstat -f -x")
    output = Nokogiri::XML(output)
    output.xpath("//Job").each do |job|
      job_owner = job.xpath("//Job_Owner")[0].content.split("@")[0]
      if job_owner == @user
        jobs.append(job)
      end
    end
    @output = jobs
    erb :jobs
  end
  
end

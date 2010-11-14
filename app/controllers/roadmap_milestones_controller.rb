#Basic crud for roadmap Milestone
class RoadmapMilestonesController < ApplicationController
  # GET /roadmap_milestones
  # GET /roadmap_milestones.xml
  def index
    @roadmap_milestones = RoadmapMilestone.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roadmap_milestones }
    end
  end

  # GET /roadmap_milestones/1
  # GET /roadmap_milestones/1.xml
  def show
    @roadmap_milestone = RoadmapMilestone.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @roadmap_milestone }
    end
  end

  # GET /roadmap_milestones/new
  # GET /roadmap_milestones/new.xml
  def new
    @roadmap_milestone = RoadmapMilestone.new
    @roadmap_milestone.project_id = params[:project_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @roadmap_milestone }
    end
  end

  # GET /roadmap_milestones/1/edit
  def edit
    @roadmap_milestone = RoadmapMilestone.find(params[:id])
    @roadmap_milestone.project_id = params[:project_id]
  end

  # POST /roadmap_milestones
  # POST /roadmap_milestones.xml
  def create
    @roadmap_milestone = RoadmapMilestone.new(params[:roadmap_milestone])
    date = nil
    if !params[:roadmap_milestone][:date].nil? && params[:roadmap_milestone][:date].length > 0
      begin
        date = DateTime.strptime(params[:roadmap_milestone][:date], current_user.date_format )
      rescue
        date = nil
      end
      @roadmap_milestone.date = tz.local_to_utc(date.to_time + 1.day - 1.minute) if date
    end

    respond_to do |format|
      if @roadmap_milestone.save
        format.html { 
          flash[:notice] = _('Milestone was successfully create.')
          redirect_to :controller => 'roadmap', :action => 'index', :id => @roadmap_milestone.project
        }
        format.xml  { render :xml => @roadmap_milestone, :status => :created, :location => @roadmap_milestone }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @roadmap_milestone.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roadmap_milestones/1
  # PUT /roadmap_milestones/1.xml
  def update
    @roadmap_milestone = RoadmapMilestone.find(params[:id])
    @old = @roadmap_milestone.clone
    @roadmap_milestone.attributes = params[:roadmap_milestone]

    date = nil
    if !params[:roadmap_milestone][:date].nil? && params[:roadmap_milestone][:date].length > 0
      begin
        date = DateTime.strptime( params[:roadmap_milestone][:date], current_user.date_format )
        @roadmap_milestone.date = tz.local_to_utc(date.to_time + 1.day - 1.minute)
      rescue Exception => e
        @roadmap_milestone.date = @old.date
      end
    end

    respond_to do |format|
      if @roadmap_milestone.save
        format.html { 
          flash[:notice] = _('Milestone was successfully updated.')
          redirect_to :controller => 'roadmap', :action => 'index', :id => @roadmap_milestone.project
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @roadmap_milestone.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roadmap_milestones/1
  # DELETE /roadmap_milestones/1.xml
  def destroy
    @roadmap_milestone = RoadmapMilestone.find(params[:id])
    @roadmap_milestone.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'roadmap', :action => 'index', :id => @roadmap_milestone.project }
      format.xml  { head :ok }
    end
  end
end

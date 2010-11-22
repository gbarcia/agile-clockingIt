class EstimationSettingsController < ApplicationController
  # GET /estimation_settings
  # GET /estimation_settings.xml
  def index
    redirect_to :action => "edit"
  end

  # GET /estimation_settings/1
  # GET /estimation_settings/1.xml
  def show
    @estimation_setting = EstimationSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @estimation_setting }
    end
  end

  # GET /estimation_settings/new
  # GET /estimation_settings/new.xml
  def new
    @estimation_setting = EstimationSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @estimation_setting }
    end
  end

  # GET /estimation_settings/1/edit
  def edit
    if params[:project_id].nil?
      last_project = current_user.projects.find :first
      project_id = last_project.id
    else
      project_id = params[:project_id]
    end
    @estimation_setting = EstimationSetting.find_by_project_id(project_id)
    @project = Project.find project_id
  end

  # POST /estimation_settings
  # POST /estimation_settings.xml
  def create
    @estimation_setting = EstimationSetting.new(params[:estimation_setting])

    respond_to do |format|
      if @estimation_setting.save
        format.html { redirect_to(@estimation_setting, :notice => 'EstimationSetting was successfully created.') }
        format.xml  { render :xml => @estimation_setting, :status => :created, :location => @estimation_setting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @estimation_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /estimation_settings/1
  # PUT /estimation_settings/1.xml
  def update
    @estimation_setting = EstimationSetting.find(params[:id])
    @project = Project.find @estimation_setting.project_id

    respond_to do |format|
      if @estimation_setting.update_attributes(params[:estimation_setting])
        format.html { 
          flash['notice'] = _("Estimation Settings was successfully saved")
          redirect_to(:action => "edit") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @estimation_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /estimation_settings/1
  # DELETE /estimation_settings/1.xml
  def destroy
    @estimation_setting = EstimationSetting.find(params[:id])
    @estimation_setting.destroy

    respond_to do |format|
      format.html { redirect_to(estimation_settings_url) }
      format.xml  { head :ok }
    end
  end
end

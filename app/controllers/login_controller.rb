# Handle logins, as well as the portal pages
#
# The portal pages should probably be moved into
# a separate controller.
#
class LoginController < ApplicationController

  layout 'login'

  def index
    render :action => 'login'
  end

  # Display the login page
  def login
    if session[:user_id]
      redirect_to :controller => 'activities', :action => 'list'
    else
      @company = company_from_subdomain
      @news ||= NewsItem.find(:all, :conditions => [ "portal = ?", true ], :order => "id desc", :limit => 3)
      render :action => 'login', :layout => false
    end
  end

  def logout
    response.headers["Content-Type"] = 'text/html'

    session[:user_id] = nil
    session[:project] = nil
    session[:sheet] = nil
    session[:group_tags] = nil
    session[:hide_dependencies] = nil
    session[:remember_until] = nil
    session[:redirect] = nil
    session[:history] = nil
    redirect_to "/"
  end

  def validate
    if params[:forgot] == 'true'
      mail_password
      redirect_to :action => 'login'
      return
    end

    @user = User.new(params[:user])
    @company = company_from_subdomain
    unless logged_in = @user.login(@company)
      flash[:notice] = "Username or password is wrong..."
      redirect_to :action => 'login'
      return
    end

    if params[:remember].to_i == 1
      session[:remember_until] = Time.now.utc + 1.month
      session[:remember] = 1
    else
      session[:remember] = 0
      session[:remember_until] = Time.now.utc + 1.hour
    end

    logged_in.save
    session[:user_id] = logged_in.id

    session[:sheet] = nil
    session[:hide_dependencies] ||= "1"

    response.headers["Content-Type"] = 'text/html'

    redirect_from_last
  end

  def signup
    @user = User.new
  end

  def take_signup

    error = 0

    unless params[:username]
      @user = User.new
      @company = Company.new
      render :action => 'signup'
      return
    end

    flash[:notice] = ""


    # FIXME: Use models validation instead
    if params[:username].length == 0
      flash[:notice] += "* Enter username<br/>"
      error = 1
    end

    if params[:password].length == 0
      flash[:notice] += "* Enter password<br/>"
      error = 1
    end

    if params[:password_again].length == 0
      flash[:notice] += "* Enter password again<br/>"
      error = 1
    end

    if params[:password_again] != params[:password]
      flash[:notice] += "* Password and Password Again don't match<br/>"
      error = 1
    end

    if params[:name].length == 0
      flash[:notice] += "* Enter your name<br/>"
      error = 1
    end

    if params[:email].length == 0
      flash[:notice] += "* Enter your email<br/>"
      error = 1
    end

    if params[:company].length == 0
      flash[:notice] += "* Enter your company name<br/>"
      error = 1
    end

    if params[:subdomain].length == 0
      flash[:notice] += "* Enter your preferred URL for company access<br/>"
      error = 1
    elsif params[:subdomain].match(/[^a-zA-Z0-9-]/) != nil
      flash[:notice] += "* Login URL can only contain letters, numbers, and hyphens, no spaces."
      error = 1
    elsif Company.count( :conditions => ["subdomain = ?", params[:subdomain]]) > 0
      flash[:notice] += "* Login url already taken. Please choose another one."
      error = 1
    end

    if error == 0
      # Create the User and Company
      @user = User.new
      @company = Company.new

      @user.name = params[:name]
      @user.username = params[:username]
      @user.password = params[:password]
      @user.email = params[:email]
      @user.time_zone = params[:user][:time_zone]
      @user.locale = params[:user][:locale]
      @user.option_externalclients = 1
      @user.option_tracktime = 1
      @user.option_tooltips = 1
      @user.date_format = "%d/%m/%Y"
      @user.time_format = "%H:%M"
      @user.admin = 1

      @company.name = params[:company]
      @company.contact_email = params[:email]
      @company.contact_name = params[:name]
      @company.subdomain = params[:subdomain].downcase.strip


      if @company.save
        @customer = Customer.new
        @customer.name = @company.name

        @company.customers << @customer
        @company.users << @user

        Signup::deliver_signup(@user, @company) rescue flash[:notice] = "Error sending registration email. Account still created.<br/>"
        redirect_to "http://#{@company.subdomain}.#{$CONFIG[:domain]}"
      end

    else
      render :action => 'signup'
    end

  end

  def company_check
    if params[:company].blank?
      render :text => "<img src=\"/images/delete.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Please choose a name.</small>"
    else
      companies = Company.count( :conditions => ["name = ?", params[:company]])
      if companies > 0
        render :text => "<img src=\"/images/error.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Company name already esists. Do you really want to create a duplicate company?</small>"
      else
        render :text => "<img src=\"/images/accept.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Name OK</small>"
      end
    end
  end

  def subdomain_check
    if params[:subdomain].nil? || params[:subdomain].empty?
      render :text => "<img src=\"/images/delete.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Please choose a domain.</small>"
    else
      subdomain = Company.count( :conditions => ["subdomain = ?", params[:subdomain]])
      if %w( www forum wiki repo mail ftp static01 new lists static ).include?( params[:subdomain].downcase )
        subdomain = 1
      end

      if params[:subdomain].match(/[^a-zA-Z0-9-]/) != nil
        render :text => "<img src=\"/images/delete.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Domain can only contain letters, numbers, and hyphens, no spaces.</small>"

      elsif subdomain > 0
        render :text => "<img src=\"/images/delete.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Domain already in use, please choose a different one.</small>"
      else
        render :text => "<img src=\"/images/accept.png\" border=\"0\" style=\"vertical-align:middle;\"/> <small>Domain OK</small>"
      end
    end
  end

  private

  # Mail the User his/her credentials for all Users on the requested
  # email address
  def mail_password
    email = (params[:user] || {})[:username]
    if email.blank?
      flash[:notice] = "Enter your email address in the username field."
      return
    end

    EmailAddress.find(:all, :conditions => { :email => email }).each do |e|
       Signup::deliver_forgot_password(e.user)
    end

    # tell user it was successful even if we didn't find the user, for security.
    flash[:notice] = "Mail sent"
  end

end

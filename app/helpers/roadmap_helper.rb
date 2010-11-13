module RoadmapHelper
  
  def options_for_user_projects (selected_project)
    projects = current_user.projects.find(:all, :include => "customer", :order => "customers.name, projects.name")

    last_customer = nil
    options = []

    projects.each do |project|
      if project.customer != last_customer
        options << [ h(project.customer.name), [] ]
        last_customer = project.customer
      end

      options.last[1] << [ project.name, project.id ]
    end

    return grouped_options_for_select(options, selected_project.id).html_safe
  end

  def get_first_project
    current_user.projects.find :first
  end
end

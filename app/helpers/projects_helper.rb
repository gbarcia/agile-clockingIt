module ProjectsHelper
  # get de project leader name
  def get_leader_name (leader_id)
    if !leader_id.nil?
      if leader_id > 0
      user =  User.find leader_id
      company_name = Company.find(user.company_id).name.upcase
      @leaderName = user.name + ' (' + company_name + ')'
      end
    else
      @leader_Name = 'No asigned'
    end
  end
end

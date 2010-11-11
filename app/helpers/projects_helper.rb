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

  def currency_is_selected? (actual_currency, select_option)
    if (actual_currency == select_option)
    return "selected='" + (actual_currency == select_option).to_s + "'"
    end
  end
end

module MilestonesHelper
  def color_is_selected? (actual_color, select_option)
    if (actual_color == select_option)
    return "selected='" + (actual_color == select_option).to_s + "'"
    end
  end
end

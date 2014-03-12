module AdsHelper

  def edit_icon
    glyphicon('pencil')
  end

  def pause_icon
    glyphicon('pause')
  end

  def play_icon
    glyphicon('play')
  end

  def delete_icon
    glyphicon('remove')
  end

  def hide_icon
    glyphicon('eye-close')
  end

  def restore_icon
    glyphicon('eye-open')
  end

  def up_icon
    glyphicon('chevron-up')
  end

  def down_icon
    glyphicon('chevron-down')
  end

  def still_icon
    glyphicon('minus')
  end

  def glyphicon(name)
    "<span class='glyphicon glyphicon-#{name}'></span>".html_safe
  end
end
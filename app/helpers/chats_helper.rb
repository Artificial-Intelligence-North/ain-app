module ChatsHelper
  def name_for(chat)
    if chat.name.present?
      chat.name
    else
      'Unnamed Chat'
    end
  end
end

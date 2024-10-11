class LogService
    def self.log_action(user, action_type, details)
      Log.create(
        user_id: user&.id, 
        action_type: action_type,
        details: details
      )
    end
  end
  
module CloakId
  # A standard error to represent problems with the cloaking process.  This error should be raised when there is a
  # problem that must be handled to ensure proper functionality.
  class CloakingError < StandardError
  end
end
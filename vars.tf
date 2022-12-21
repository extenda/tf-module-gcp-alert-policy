variable project {
  type        = string
  description = "Project ID to create monitoring resources in"
}

variable default_user_labels {
  type        = map(any)
  description = "User labels set on all alerts"
  default     = {}
}

variable default_notification_channels {
  type        = list(any)
  description = "Notificaton channel IDs set on all alerts"
  default     = []
}

variable policies {
  type        = any
  description = "List of the actual alert configs"
}
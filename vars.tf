variable project {
  type        = string
  description = "Project ID to create the alerts in"
}

variable policies {
  type        = any
  description = "List of the actual alert configs"
}

variable default_user_labels {
  type        = map(any)
  description = "User labels to be set for all alerts"
  default     = {}
}

variable default_notification_channels {
  type        = list(any)
  description = "Notificaton channel IDs to be set on all alerts"
  default     = []
}

variable "notification_channels_output" {
  type        = map(any)
  description = "A map, holding the name of the "
  default     = {}
}

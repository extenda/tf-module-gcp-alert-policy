variable "project" {
  type        = string
  description = "Project ID to create the alerts in"
}

variable "policies" {
  type        = any
  description = "List of the actual alert configs"
}

variable "default_user_labels" {
  type        = map(any)
  description = "User labels to be set for all alerts"
  default     = {}
}

variable "default_notification_channels" {
  type        = list(any)
  description = "List of display names for notification channels to be set for all alerts"
  default     = []
}

variable "notification_channel_ids" {
  type        = map(string)
  description = "To be able to provide channels display name instead of id/name, should be { display_name: name } or output from tf-module-gcp-notification-channels"
  default     = {}
}

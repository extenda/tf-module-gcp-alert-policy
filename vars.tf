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
  description = "User labels to be set for __all__ alerts"
  default     = {}
}

variable "fallback_notification_channels" {
  type        = list(any)
  description = "List of 'display names' or 'id' for NCs to be set for all alerts that don't provide 'notificaiton_channels'"
  default     = []
}

variable "notification_channel_ids" {
  type        = map(string)
  description = "Enables you to provide the the NCs 'display name' instead of 'id', { nc_display_name: nc_id  } or output from tf-module-gcp-notification-channels"
  default     = {}
}

module "alert" {
  source                         = "../"
  project                        = "<my-project-id>"
  policies                       = yamldecode(file("alerts.yaml"))
  fallback_notification_channels = ["#fallback-channel", "projects/<project-id>/notificationChannels/<nc-id>"]
  notification_channel_ids = {
    "#fallback-channel" : "projects/my_project/notificationChannels/id-for-fallback-channel",
    "#notification_channel" : "projects/my_project/notificationChannels/id-for-fallback-channel"
  }
  default_user_labels = {
    cc = "all-alerts-will-have-this-label"
  }
}



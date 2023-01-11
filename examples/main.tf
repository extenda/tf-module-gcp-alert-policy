module "alert" {
  source                        = "../"
  project                       = "<my-project-id>"
  policies                      = yamldecode(file("alerts.yaml"))
  default_notification_channels = ["#all-alerts-will-alert-to-this-slack-channel", "projects/<project-id>/notificationChannels/<nc-id>"]
  notification_channel_ids      = { "#all-alerts-will-alert-to-this-slack-channel" : "projects/my_project/notificationChannels/id-for-this-notification-channel" }
  default_user_labels = {
    cc = "all-alerts-will-have-this-label"
  }
}

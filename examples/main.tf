module "alert" {
  source                        = "../"
  project                       = "<my-project-id>"
  policies                      = yamldecode(file("alerts.yaml"))
  default_notification_channels = ["projects/<project-id>/notificationChannels/<id>"]
  default_user_labels = {
    cc = "all-alerts-will-have-this-label"
  }
}

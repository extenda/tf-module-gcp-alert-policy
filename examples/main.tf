module "alert" {
  source                        = "../"
  project                       = "<my-project-id>"
  policies                      = yamldecode(file("alerts.yaml"))
  default_notification_channels = ["#all-alerts-will-alert-to-this-slack-channel"]
  default_user_labels = {
    cc = "all-alerts-will-have-this-label"
  }
}

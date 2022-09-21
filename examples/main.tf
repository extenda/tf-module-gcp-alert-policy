module alert {
  source                = "../"
  monitoring_project_id = "hiiretail-monitoring-prod-6500"
  notification_channels = ["projects/testproject/notificationChannels/channel_id"]
  policies              = yamldecode(file("alerts.yaml"))
}

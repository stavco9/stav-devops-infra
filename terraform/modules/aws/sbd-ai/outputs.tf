output "sbd_ai_videos_bucket" {
  value = local.sbd_ai_videos_bucket
}

output "sbd_ai_mongodb_cluster" {
  value = local.sbd_ai_mongodb_cluster
}

output "sbd_ai_mongodb_connection_string" {
  value = mongodbatlas_cluster.sbd_ai[0].connection_strings
}
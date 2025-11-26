output "bucket_name" {
  description = "Name of the GCS bucket"
  value       = google_storage_bucket.demo.name
}

output "bucket_url" {
  description = "URL of the GCS bucket"
  value       = google_storage_bucket.demo.url
}

output "bucket_self_link" {
  description = "Self-link of the GCS bucket"
  value       = google_storage_bucket.demo.self_link
}

output "bucket_location" {
  description = "Location where the GCS bucket is created"
  value       = google_storage_bucket.demo.location
}

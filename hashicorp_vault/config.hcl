ui = true


#for raft system Storage

#storage "raft" {
 # path    = "./vault/data"
 # node_id = "node1"
#}



# For S3 Storage 
storage "s3" {
  access_key = "ACCESS_KEY"
  secret_key = "AWS_SECRET_KEY"
  bucket     = "BUCKET_NAME"
  region     = "ap-south-1"
  path       = "./vault"
}


listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
  proxy_protocol_behavior = "use_always"
}

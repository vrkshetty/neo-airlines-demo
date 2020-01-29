# resource "aws_s3_bucket" "s3_bucket" {
#   bucket = "neo-airlines-demo"
#   acl    = "private"
#   versioning {
#     enabled = true
#   }
#   tags = {
#     Name = "${var.PREFIX}-s3"
#   }
# }

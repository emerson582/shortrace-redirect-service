resource "aws_dynamodb_table" "urls_table" {
  name         = "shortrace-urls"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "code"

  attribute {
    name = "code"
    type = "S"
  }
}

resource "aws_dynamodb_table" "metrics_table" {
  name         = "shortrace-metrics"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "code"
  range_key = "timestamp"

  attribute {
    name = "code"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}
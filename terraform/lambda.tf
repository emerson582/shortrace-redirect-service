data "archive_file" "redirect_zip" {
  type        = "zip"
  source_dir  = "./dist"
  output_path = "./redirect_url.zip"
}

resource "aws_lambda_function" "redirect_lambda" {
  function_name = "shortrace-redirect"

  filename         = data.archive_file.redirect_zip.output_path
  source_code_hash = data.archive_file.redirect_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs22.x"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      URL_TABLE     = data.aws_dynamodb_table.urls_table.name
      METRICS_TABLE = aws_dynamodb_table.metrics_table.name
      REGION        = var.region
    }
  }
}
data "archive_file" "redirect_zip" {
  type        = "zip"
  source_dir  = "../lambdas/redirect_url"
  output_path = "../lambdas/redirect_url.zip"
}

resource "aws_lambda_function" "redirect_lambda" {

  function_name = "shortrace-redirect"

  filename         = data.archive_file.redirect_zip.output_path
  source_code_hash = data.archive_file.redirect_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs18.x"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      URL_TABLE = aws_dynamodb_table.urls_table.name
      REGION    = "us-east-1"
    }
  }
}
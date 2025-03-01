provider "aws" {
  region = var.region
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-chuck-bot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_layer_version" "discord_layer" {
  filename         = "${path.module}/../lambda_layer/discord_layer.zip"  
  layer_name       = "discord-layer"
  compatible_runtimes = ["python3.10"]  
}

resource "aws_lambda_function" "chuck-bot-lambda" {
  function_name = "chuck-bot-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"  
  runtime       = "python3.10"  

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout       = 15
  
  environment {
    variables = {
      DISCORD_TOKEN      = var.discord_token
      DISCORD_CHANNEL_ID = var.discord_channel_id
    }
  }
  layers = [
    aws_lambda_layer_version.discord_layer.arn
  ]
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "chuck-bot-schedule"
  description         = "Trigger Lambda every day"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.chuck-bot-lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chuck-bot-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}

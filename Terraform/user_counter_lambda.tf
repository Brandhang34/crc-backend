resource "aws_dynamodb_table_item" "ddbtable" {
  table_name = aws_dynamodb_table.ddbtable.name
  hash_key   = aws_dynamodb_table.ddbtable.hash_key
  item = <<ITEM
{
  "id": {"S": "visitor"},
  "count": {"N": "0"}
}
ITEM
}
resource "aws_dynamodb_table" "ddbtable" {
  name             = "Portfolio_VisitCounter"
  hash_key         = "id"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
}


# ************************ Create User Counter Lambda Function ************************

resource "aws_iam_role" "user_counter_lambda_role" {
name   = "User_Counter_Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "user_counter_iam_policy_for_lambda" {
 name         = "ConnectDynamoDBLambdaFunction"
 path         = "/"
 description  = "Allow get and put requests to DynamoDB via lambda"
 policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:513282148621:table/Portfolio_VisitCounter"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_user_counter_iam_policy_to_iam_role" {
    role        = aws_iam_role.user_counter_lambda_role.name
    policy_arn  = aws_iam_policy.user_counter_iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_user_counter_python_code" {
    type        = "zip"
    source_file  = "../LambdaFunctions/VisitCountFunction/lambda_function.py"
    output_path = "../LambdaFunctions/VisitCountFunction/lambda_function.zip"
}

resource "aws_lambda_function" "user_counter_lambda_func" {
    filename                       = "../LambdaFunctions/VisitCountFunction/lambda_function.zip"
    function_name                  = "User_Counter_Lambda_Function"
    role                           = aws_iam_role.user_counter_lambda_role.arn
    handler                        = "lambda_function.lambda_handler"
    runtime                        = "python3.9"
    depends_on                     = [aws_iam_role_policy_attachment.attach_user_counter_iam_policy_to_iam_role]
    environment {
    variables = {
      TABLE_NAME = "Portfolio_VisitCounter"
    }
  }
}
resource "aws_iam_role" "contact_form_lambda_role" {
name   = "Contact_Form_Lambda_Function_Role"
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

resource "aws_iam_policy" "contact_form_iam_policy_for_lambda" {
 name         = "AmazonSESAllowAccessLambdaFunction"
 path         = "/"
 description  = "Allow Email to be send to Amazon SES"
 policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_contact_form_iam_policy_to_iam_role" {
    role        = aws_iam_role.contact_form_lambda_role.name
    policy_arn  = aws_iam_policy.contact_form_iam_policy_for_lambda.arn
}

# TODO Change "zip_the_javascript_code" to something else

data "archive_file" "zip_the_contact_form_javascript_code" {
    type        = "zip"
    source_file  = "../LambdaFunctions/SimpleEmailServiceFunction/PortfolioSESLambdaFunction.js"
    output_path = "../LambdaFunctions/SimpleEmailServiceFunction/PortfolioSESLambdaFunction.zip"
}

resource "aws_lambda_function" "contact_form_lambda_func" {
    filename                       = "../LambdaFunctions/SimpleEmailServiceFunction/PortfolioSESLambdaFunction.zip"
    function_name                  = "Contact_Form_Lambda_Function"
    role                           = aws_iam_role.contact_form_lambda_role.arn
    handler                        = "PortfolioSESLambdaFunction.handler"
    runtime                        = "nodejs20.x"
    depends_on                     = [aws_iam_role_policy_attachment.attach_contact_form_iam_policy_to_iam_role]
    environment {
    variables = {
      SOURCE_EMAIL_ADDRESS = "brandonhang.business@gmail.com"
      TO_EMAIL_ADDRESS = "brandonhang34@outlook.com"
    }
  }
}

var aws = require("aws-sdk");
var ses = new aws.SES({ region: "us-east-1" });
exports.handler = async function (event) {
  var params = {
    Destination: {
      ToAddresses: System.getenv("TO_EMAIL_ADDRESS"),
    },
    Message: {
      Body: {
        Text: {
          Data:
            "name: " +
            event.name +
            "\nemail: " +
            event.email +
            "\nmessage: " +
            event.message,
        },
      },

      Subject: { Data: event.subject },
    },
    Source: System.getenv("SOURCE_EMAIL_ADDRESS"),
  };

  return ses.sendEmail(params).promise();
};

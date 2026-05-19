const {
  DynamoDBClient,
  GetItemCommand
} = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({
  region: process.env.REGION
});

exports.handler = async (event) => {

  try {

    const code = event.pathParameters?.codigo;

    if (!code) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "Código requerido"
        })
      };
    }

    const result = await client.send(
      new GetItemCommand({
        TableName: process.env.URL_TABLE,
        Key: {
          code: { S: code }
        }
      })
    );

    if (!result.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: "URL no encontrada"
        })
      };
    }

    const originalUrl = result.Item.originalUrl.S;

    return {
      statusCode: 302,
      headers: {
        Location: originalUrl
      }
    };

  } catch (error) {

    console.error(error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Error interno"
      })
    };
  }
};
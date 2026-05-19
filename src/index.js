const {
  DynamoDBClient,
  GetItemCommand,
  PutItemCommand
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
        body: JSON.stringify({ message: "Código requerido" })
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
        body: JSON.stringify({ message: "URL no encontrada" })
      };
    }

    const originalUrl = result.Item.originalUrl.S;

    const now = new Date();
    const timestamp = now.toISOString();
    const dateOnly = timestamp.split('T')[0];
    const userAgent = event.headers?.['User-Agent'] || event.headers?.['user-agent'] || "Unknown";

    try {
      await client.send(
        new PutItemCommand({
          TableName: process.env.METRICS_TABLE,
          Item: {
            code: { S: code },
            timestamp: { S: timestamp },
            dateOnly: { S: dateOnly || "" },
            userAgent: { S: userAgent }
          }
        })
      );
    } catch (dbError) {
      console.error("Fallo al guardar la métrica, pero procediendo a redirigir:", dbError);
    }

    return {
      statusCode: 302,
      headers: {
        Location: originalUrl,
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true
      }
    };

  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Error interno" })
    };
  }
};
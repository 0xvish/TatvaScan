<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gemini RAG Chat</title>
  </head>
  <body>
    <h1>Ask your question</h1>
    <form action="GeminiServlet" method="POST">
      <label for="userMessage">Your Question:</label>
      <input type="text" id="userMessage" name="userMessage" required />
      <button type="submit">Ask</button>
    </form>

    <h2>Answer:</h2>
    <p id="answer">${answer}</p>
  </body>
</html>

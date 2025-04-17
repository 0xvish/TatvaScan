<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ page
import="java.net.URLEncoder" %> <% String answer = (String)
request.getAttribute("answer"); String jsSafeAnswer = ""; if (answer != null) {
jsSafeAnswer = answer .replace("\\", "\\\\") .replace("`", "\\`") .replace("$",
"\\$") .replace("\"", "\\\"") .replace("\n", "\\n") .replace("\r", ""); } %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>TatvaScan - Ingredient Safety Checker</title>
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
    />
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@4.0.2/dist/tesseract.min.js"></script>
    <style>
      body {
        background: #f5f9ff;
        font-family: "Segoe UI", sans-serif;
      }
      .container {
        max-width: 700px;
        margin-top: 60px;
      }
      .card {
        border: none;
        border-radius: 15px;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.05);
      }
      .btn-custom {
        background-color: #007bff;
        color: white;
      }
      .btn-custom:hover {
        background-color: #0056b3;
      }
      .footer {
        margin-top: 60px;
        font-size: 14px;
        color: #888;
      }
      #preview {
        max-width: 100%;
        max-height: 300px;
        margin-top: 10px;
        border-radius: 10px;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="card p-4 text-center">
        <h2 class="mb-4">🧪 TatvaScan</h2>
        <p class="text-muted mb-3">
          Scan & check ingredients for safety or allergens
        </p>

        <div class="d-grid gap-2">
          <button class="btn btn-custom" onclick="openFileInput()">
            📁 Upload Image
          </button>
          <button class="btn btn-custom" onclick="openCamera()">
            📸 Scan with Camera
          </button>
        </div>

        <img id="preview" class="img-fluid d-none" />

        <form
          id="scanForm"
          action="GeminiServlet"
          method="post"
          style="display: none"
        >
          <input type="hidden" name="ingredients" id="hiddenIngredients" />
        </form>

        <% if (answer != null) { %>
        <div class="mt-4 text-start">
          <h5>🔍 Analysis Result:</h5>
          <div id="markdown-result" class="border rounded p-3 bg-light"></div>
          <script>
            const markdown = "<%= jsSafeAnswer %>";
            document.getElementById("markdown-result").innerHTML =
              marked.parse(markdown);
          </script>
        </div>
        <% } %>
      </div>

      <div class="footer text-center mt-4">
        Built with ☕ by
        <a href="https://github.com/0xVish" target="_blank">0xVish</a>
      </div>
    </div>

    <!-- JS OCR logic -->
    <script>
      function openFileInput() {
        const input = document.createElement("input");
        input.type = "file";
        input.accept = "image/*";
        input.onchange = (e) => handleImage(e.target.files[0]);
        input.click();
      }

      function openCamera() {
        const input = document.createElement("input");
        input.type = "file";
        input.accept = "image/*";
        input.capture = "environment";
        input.onchange = (e) => handleImage(e.target.files[0]);
        input.click();
      }

      function handleImage(file) {
        const reader = new FileReader();
        reader.onload = function (e) {
          document.getElementById("preview").classList.remove("d-none");
          document.getElementById("preview").src = e.target.result;

          Tesseract.recognize(e.target.result, "eng")
            .then(({ data: { text } }) => {
              const cleaned = text.replace(/\s+/g, " ").trim();
              document.getElementById("hiddenIngredients").value = cleaned;
              document.getElementById("scanForm").submit();
            })
            .catch((err) => {
              alert("OCR failed: " + err.message);
            });
        };
        reader.readAsDataURL(file);
      }
    </script>
  </body>
</html>

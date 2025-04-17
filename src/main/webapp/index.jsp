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
        animation: fadeIn 0.5s ease-in-out;
      }

      @keyframes fadeIn {
        from {
          opacity: 0;
          transform: translateY(20px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .btn-custom {
        background-color: #007bff;
        color: white;
        transition: all 0.2s ease;
      }

      .btn-custom:hover {
        background-color: #0056b3;
      }

      .footer {
        margin-top: 60px;
        font-size: 14px;
        color: #888;
      }

      #preview,
      #cameraStream {
        max-width: 100%;
        max-height: 300px;
        margin-top: 10px;
        border-radius: 10px;
      }

      #loader {
        display: none;
        margin-top: 15px;
      }

      .spinner-border {
        width: 2.5rem;
        height: 2.5rem;
      }

      #statusText {
        font-size: 14px;
        color: #555;
        margin-top: 10px;
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
          <button
            class="btn btn-custom"
            onclick="openFileInput()"
            id="uploadBtn"
          >
            📁 Upload Image
          </button>
          <button class="btn btn-custom" onclick="openCamera()" id="cameraBtn">
            📸 Scan with Camera
          </button>
        </div>

        <video id="cameraStream" class="d-none" autoplay playsinline></video>
        <button
          id="captureBtn"
          class="btn btn-custom mt-2 d-none"
          onclick="captureFromCamera()"
        >
          📷 Capture
        </button>

        <canvas id="canvas" class="d-none"></canvas>
        <img id="preview" class="img-fluid d-none" />
        <div id="statusText" class="text-center"></div>

        <!-- Loader -->
        <div id="loader" class="text-center">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 text-muted">Processing, please wait...</p>
        </div>

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

    <!-- JS -->
    <script>
      let stream;

      function showLoader(message) {
        document.getElementById("loader").style.display = "block";
        document.getElementById("statusText").innerText = message || "";
        document.getElementById("uploadBtn").disabled = true;
        document.getElementById("cameraBtn").disabled = true;
        document.getElementById("captureBtn").disabled = true;
      }

      function hideLoader() {
        document.getElementById("loader").style.display = "none";
        document.getElementById("statusText").innerText = "";
        document.getElementById("uploadBtn").disabled = false;
        document.getElementById("cameraBtn").disabled = false;
        document.getElementById("captureBtn").disabled = false;
      }

      function openCamera() {
        const video = document.getElementById("cameraStream");
        const captureBtn = document.getElementById("captureBtn");

        navigator.mediaDevices
          .getUserMedia({ video: { facingMode: "environment" } })
          .then((mediaStream) => {
            stream = mediaStream;
            video.srcObject = mediaStream;
            video.classList.remove("d-none");
            captureBtn.classList.remove("d-none");
          })
          .catch((err) => {
            alert("Camera access denied: " + err.message);
          });
      }

      function captureFromCamera() {
        const video = document.getElementById("cameraStream");
        const canvas = document.getElementById("canvas");
        const context = canvas.getContext("2d");

        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        context.drawImage(video, 0, 0, canvas.width, canvas.height);

        const dataURL = canvas.toDataURL("image/png");
        document.getElementById("preview").src = dataURL;
        document.getElementById("preview").classList.remove("d-none");

        stream.getTracks().forEach((track) => track.stop());
        video.classList.add("d-none");
        document.getElementById("captureBtn").classList.add("d-none");

        showLoader("Reading ingredients from camera...");
        Tesseract.recognize(dataURL, "eng")
          .then(({ data: { text } }) => {
            const cleaned = text.replace(/\s+/g, " ").trim();
            document.getElementById("hiddenIngredients").value = cleaned;
            showLoader("Submitting for analysis...");
            document.getElementById("scanForm").submit();
          })
          .catch((err) => {
            hideLoader();
            alert("OCR failed: " + err.message);
          });
      }

      function openFileInput() {
        const input = document.createElement("input");
        input.type = "file";
        input.accept = "image/*";
        input.onchange = (e) => handleImageUpload(e.target.files[0]);
        input.click();
      }

      function handleImageUpload(file) {
        const reader = new FileReader();
        reader.onload = function (e) {
          const dataURL = e.target.result;
          document.getElementById("preview").src = dataURL;
          document.getElementById("preview").classList.remove("d-none");

          showLoader("Reading ingredients from uploaded image...");
          Tesseract.recognize(dataURL, "eng")
            .then(({ data: { text } }) => {
              const cleaned = text.replace(/\s+/g, " ").trim();
              document.getElementById("hiddenIngredients").value = cleaned;
              showLoader("Submitting for analysis...");
              document.getElementById("scanForm").submit();
            })
            .catch((err) => {
              hideLoader();
              alert("OCR failed: " + err.message);
            });
        };
        reader.readAsDataURL(file);
      }
    </script>
  </body>
</html>

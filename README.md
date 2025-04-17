# 🧪 TatvaScan - Ingredient Safety Checker

TatvaScan is a web application that lets users scan ingredients from images using OCR (Tesseract.js) and checks them for safety or allergens using a powerful LLM backend like Gemini.

---

## 🚀 Features

- 📁 Upload image or 📸 capture via camera
- 🔍 OCR-based ingredient extraction
- 🧠 LLM-powered ingredient safety check
- 🧼 Clean UI with Markdown rendering
- 📱 Mobile-friendly and responsive

---

## 🧰 Tech Stack

- **Frontend**: HTML, JSP, Bootstrap, JavaScript, Tesseract.js, Marked.js
- **Backend**: Java Servlet
- **OCR Engine**: Tesseract.js (browser-based)
- **LLM Integration**: Gemini (via API in Servlet)
- **Server**: Apache Tomcat
- **Build Tool**: Maven

---

## 📦 Local Setup Instructions

### 1. ✅ Prerequisites

Make sure you have the following installed:

- Java JDK 8 or later
- Apache Maven
- Apache Tomcat (v9 or v10 recommended)
- Git (optional, for cloning)

---

### 2. ⬇️ Clone the Repository

```bash
git clone https://github.com/0xVish/tatvascan.git
cd tatvascan
```

---

### 3. ⚙️ Set Environment Variables

> Instead of using a `.env` file, this project uses **system environment variables** for API keys and other secrets.

Set these environment variables **in your terminal session** or OS-level settings:

#### On **Linux/macOS**:

```bash
export GEMINI_API_KEY=your_gemini_api_key
```

#### On **Windows (CMD)**:

```cmd
set GEMINI_API_KEY=your_gemini_api_key
```

Make sure this is set before running the app. You can also add it permanently via `.bashrc`, `.zshrc`, or Windows Environment Variable GUI.

---

### 4. 📦 Build the Project with Maven

```bash
mvn clean package
```

This will generate a `.war` file in the `target/` directory.

---

### 5. 🚀 Deploy to Tomcat

#### Option 1: Using WAR file

- Copy the generated WAR file (`target/tatvascan.war`) into your Tomcat's `webapps/` directory.
- Start/restart the Tomcat server.

#### Option 2: Using the full target folder (for exploded deployment)

- Copy the entire `target/tatvascan/` folder into Tomcat's `webapps/` directory.
- Ensure the structure remains intact (`WEB-INF`, `index.jsp`, etc.).

---

### 6. 🌐 Run the App

After starting Tomcat, visit:

```
http://localhost:8080/tatvascan
```

---

## 📸 Screenshots

| Upload & Capture             | Ingredient Analysis            |
| ---------------------------- | ------------------------------ |
| ![image](https://github.com/user-attachments/assets/8a1e5871-4dd4-420c-9ef5-70abd2ad4f42) | ![image](https://github.com/user-attachments/assets/9bf1573e-910a-4c70-9095-bb1cb62d4a38) |

---

## 🧠 Behind the Scenes

- `GeminiServlet.java`: Handles POST request with OCR text and queries the Gemini API for analysis.
- Tesseract.js runs completely in-browser for privacy and speed.
- Ingredients are sanitized and passed as Markdown for rich output formatting.

---

## 🛠 Troubleshooting

- **OCR not working?** Check console for `Tesseract` errors.
- **No response from backend?** Ensure environment variable `GEMINI_API_KEY` is set and servlet is mapped correctly.
- **Tomcat not deploying?** Make sure the WAR or folder is correctly placed under `webapps`.

---

## ❤️ Credits

Made with ☕, 🧠 and 💡 by [0xVish](https://github.com/0xVish)

---

## 📜 License

MIT License

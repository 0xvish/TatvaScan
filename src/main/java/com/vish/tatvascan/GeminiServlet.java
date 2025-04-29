package com.vish.tatvascan;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.loader.FileSystemDocumentLoader;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.model.googleai.GoogleAiGeminiChatModel;
import dev.langchain4j.rag.content.retriever.EmbeddingStoreContentRetriever;
import dev.langchain4j.service.AiServices;
import dev.langchain4j.store.embedding.inmemory.InMemoryEmbeddingStore;
import dev.langchain4j.store.embedding.EmbeddingStoreIngestor;

public class GeminiServlet extends HttpServlet {

    interface Assistant {
        String chat(String userMessage);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Step 1: Get ingredients from the JSP
        String ingredientInput = request.getParameter("ingredients");
        if (ingredientInput == null || ingredientInput.trim().isEmpty()) {
            request.setAttribute("answer", "Please enter a list of ingredients.");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        // Step 2: Build query message
        String userQuery = buildQueryFromIngredients(ingredientInput);
        // Step 3: Load documents & setup embedding
        List<Document> documents = FileSystemDocumentLoader.loadDocuments("/documents");
        InMemoryEmbeddingStore<TextSegment> embeddingStore = new InMemoryEmbeddingStore<>();
        EmbeddingStoreIngestor.ingest(documents, embeddingStore);

        // Step 4: Set up Gemini model
        GoogleAiGeminiChatModel gemini = GoogleAiGeminiChatModel.builder()
                .apiKey(System.getenv("TATVASCAN_GEMINI_API_KEY"))
                .modelName("gemini-1.5-flash")
                .build();

        Assistant assistant = AiServices.builder(Assistant.class)
                .chatLanguageModel(gemini)
                .chatMemory(MessageWindowChatMemory.withMaxMessages(10))
                .contentRetriever(EmbeddingStoreContentRetriever.from(embeddingStore))
                .build();

        // Step 5: Get Gemini response
        String geminiResponse = assistant.chat(userQuery);

        // Step 6: Pass result to JSP
        request.setAttribute("answer", geminiResponse);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    private String buildQueryFromIngredients(String input) {
        String[] ingredients = input.split(",");
        StringBuilder queryBuilder = new StringBuilder();
    
        queryBuilder.append("You are an expert toxicologist and AI assistant. ")
                    .append("Analyze the following list of ingredients using the context documents provided. ")
                    .append("For ingredients not found in the context, rely on your internal knowledge, but clearly mark them as such.\n\n");
    
        queryBuilder.append("### 🧪 Ingredients to Analyze:\n");
        for (String ingredient : ingredients) {
            queryBuilder.append("- ").append(ingredient.trim()).append("\n");
        }
    
        queryBuilder.append("\n---\n")
                    .append("Please respond in the **Markdown** format below to enable structured display:\n\n")
    
                    .append("### 🚩 Flagged Ingredients\n")
                    .append("List harmful or allergenic ingredients using the format:\n")
                    .append("`Ingredient Name` — **Severity:** ☠️ / ❗ / ⚠️  \n")
                    .append("_Short reason why it’s flagged._\n\n")
    
                    .append("**Example:**\n")
                    .append("`Parabens` — **Severity:** ❗  \n")
                    .append("_May cause hormone disruption and allergic reactions._\n\n")
    
                    .append("### 💥 Side Effects\n")
                    .append("Provide bullet points summarizing known side effects of flagged ingredients:\n")
                    .append("- Headaches\n")
                    .append("- Skin irritation\n")
                    .append("- Endocrine disruption\n\n")
    
                    .append("### 🧠 Notes & Source\n")
                    .append("Indicate whether the analysis was based on context documents or general knowledge.\n")
                    .append("For example:\n")
                    .append("- `Sodium Benzoate` was found in the provided documents.\n")
                    .append("- `Benzophenone` was not found in the context, so explanation is based on known scientific data.\n");
    
        return queryBuilder.toString();
    }
    
}

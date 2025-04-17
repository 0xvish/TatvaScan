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
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dev.langchain4j.store.embedding.EmbeddingStoreIngestor;

public class GeminiServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userMessage = request.getParameter("userMessage");

        interface Assistant {
            String chat(String userMessage);
        }

        // Load documents and setup embedding store
        List<Document> documents = FileSystemDocumentLoader.loadDocuments("C:\\apache-tomcat-9.0.102\\ajava\\langchain4j-demo\\documents");
        InMemoryEmbeddingStore<TextSegment> embeddingStore = new InMemoryEmbeddingStore<>();
        EmbeddingStoreIngestor.ingest(documents, embeddingStore);

        // Setup Gemini chat model
        GoogleAiGeminiChatModel gemini = GoogleAiGeminiChatModel.builder()
            .apiKey(System.getenv("TATVASCAN_GEMINI_API_KEY"))
            .modelName("gemini-1.5-flash")
            .build();

        Assistant assistant = AiServices.builder(Assistant.class)
            .chatLanguageModel(gemini)
            .chatMemory(MessageWindowChatMemory.withMaxMessages(10))
            .contentRetriever(EmbeddingStoreContentRetriever.from(embeddingStore))
            .build();

        // Get the response from the assistant
        String answer = assistant.chat(userMessage);

        // Set the answer as a request attribute to display it on the JSP
        request.setAttribute("answer", answer);

        // Forward the request to the JSP page
        RequestDispatcher dispatcher = request.getRequestDispatcher("/index.jsp");
        dispatcher.forward(request, response);
    }
}

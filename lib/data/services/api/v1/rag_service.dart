import 'package:flutter/foundation.dart';
import 'package:anttec_movil/data/services/api/v1/product_service.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_mistralai/langchain_mistralai.dart';

class RagService {
  final String mistralApiKey = 'PsWhPsdkSBZu2Oo3NAZavxdbNjSJ3ZNp';

  late final ChatMistralAI _llm;
  late final MistralAIEmbeddings _embeddings;
  MemoryVectorStore? _vectorStore;
  bool isIndexed = false;

  RagService() {
    _llm = ChatMistralAI(
      apiKey: mistralApiKey,
      defaultOptions: const ChatMistralAIOptions(
        model: 'mistral-small-latest',
        temperature: 0.0,
      ),
    );
    _embeddings = MistralAIEmbeddings(apiKey: mistralApiKey);
  }

  Future<void> indexProducts() async {
    if (isIndexed) return;

    try {
      debugPrint("🔄 RAG: Indexando catálogo...");
      final productService = ProductService();
      final response = await productService.productAll(page: 1);
      final products = response.data;

      if (products.isEmpty) return;

      final documents = products.map((prod) {
        // ✅ CORREGIDO: Quitamos los '?? ""' porque tu modelo ya asegura que no son nulos
        final pName = prod.name;
        final pCategory = prod.category;
        final pBrand = prod.brand; // Antes: prod.brand ?? ""
        final pDesc = prod.description; // Antes: prod.description ?? ""

        // Unimos todo para buscar pistas
        final fullText = "$pName $pBrand $pCategory $pDesc".toLowerCase();

        String tipoDispositivo = "OTRO";

        // Lógica de detección "Sherlock Holmes" 🕵️‍♂️
        if (fullText.contains('mouse') ||
            fullText.contains('raton') ||
            fullText.contains('ratón') ||
            fullText.contains('sensor')) {
          tipoDispositivo = "MOUSE";
        } else if (fullText.contains('teclado') ||
            fullText.contains('keyboard') ||
            fullText.contains('key') ||
            fullText.contains('switch')) {
          tipoDispositivo = "TECLADO";
        } else if (fullText.contains('audi') ||
            fullText.contains('auric') ||
            fullText.contains('headset') ||
            fullText.contains('sound') ||
            fullText.contains('diadema') ||
            fullText.contains('casco') ||
            fullText.contains('ear') ||
            fullText.contains('pro x') ||
            fullText.contains('g435')) {
          tipoDispositivo = "AUDÍFONO";
        }

        final content = """
          [[FICHA TÉCNICA]]
          - TIPO CLASIFICADO: $tipoDispositivo
          - Nombre: $pName
          - Marca: $pBrand
          - Precio: S/. ${prod.price.toStringAsFixed(2)}
          - Stock: ${prod.stock}
        """;

        return Document(
          pageContent: content,
          metadata: {'id': prod.id.toString(), 'name': pName},
        );
      }).toList();

      _vectorStore = MemoryVectorStore(embeddings: _embeddings);
      await _vectorStore!.addDocuments(documents: documents);

      isIndexed = true;
      debugPrint("✅ RAG: Base de datos lista.");
    } catch (e) {
      debugPrint("❌ RAG Error: $e");
    }
  }

  Future<String> askQuestion(String userQuery) async {
    if (!isIndexed || _vectorStore == null) await indexProducts();
    if (_vectorStore == null) return "Conectando...";

    try {
      final retriever = _vectorStore!.asRetriever(
        defaultOptions: const VectorStoreRetrieverOptions(
          searchType: VectorStoreSimilaritySearch(k: 20),
        ),
      );

      final prompt = PromptTemplate.fromTemplate("""
        Eres el Vendedor de Anttec.
        
        PREGUNTA: "{question}"
        INVENTARIO:
        {context}
        
        INSTRUCCIONES:
        1. Identifica qué quiere el cliente (Mouse, Teclado o Audífono).
        2. FILTRA:
           - Si pide AUDÍFONOS, usa solo los de TIPO CLASIFICADO: AUDÍFONO.
           - Si pide MOUSE, usa solo TIPO CLASIFICADO: MOUSE.
           - Ignora el resto.
        3. Responde con la lista limpia.
        
        FORMATO:
        • **[Nombre]** 💰 **S/. [Precio]** (Stock: [Stock])
        
        Si no hay nada tras filtrar, di: "No encontré ese producto."

        Respuesta:
      """);

      final chain = RetrievalQAChain(
        retriever: retriever,
        combineDocumentsChain: StuffDocumentsChain(
          llmChain: LLMChain(llm: _llm, prompt: prompt),
        ),
      );

      final result = await chain.invoke({'query': userQuery});
      return result['result']?.toString() ?? "Error.";
    } catch (e) {
      return "Error técnico: $e";
    }
  }
}

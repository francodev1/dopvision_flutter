// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// 🔥 Firestore Service
/// 
/// Wrapper para operações complexas do Firestore:
/// - Transactions
/// - Batch writes
/// - Queries complexas
/// - Aggregations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================
  // 📝 Transactions
  // ============================================

  /// Executa uma transação
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      AppLogger.info('🔄 Iniciando transação');

      final result = await _firestore.runTransaction(transactionHandler);

      AppLogger.info('✅ Transação concluída');
      return result;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro na transação', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado na transação', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Transfere dados entre documentos (exemplo: mover venda entre clientes)
  Future<void> transferDocument({
    required String fromCollection,
    required String fromDocId,
    required String toCollection,
    required String toDocId,
    Map<String, dynamic>? additionalData,
  }) async {
    await runTransaction((transaction) async {
      // Ler documento original
      final fromDoc = await transaction.get(
        _firestore.collection(fromCollection).doc(fromDocId),
      );

      if (!fromDoc.exists) {
        throw Exception('Documento origem não encontrado');
      }

      final data = fromDoc.data()!;
      
      // Adicionar dados extras se fornecidos
      if (additionalData != null) {
        data.addAll(additionalData);
      }

      // Criar no destino
      transaction.set(
        _firestore.collection(toCollection).doc(toDocId),
        data,
      );

      // Deletar da origem
      transaction.delete(fromDoc.reference);
    });

    AppLogger.info('✅ Documento transferido');
  }

  // ============================================
  // 📦 Batch Writes
  // ============================================

  /// Cria um batch para múltiplas operações
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// Executa múltiplas operações em batch
  Future<void> executeBatch(
    void Function(WriteBatch batch) operations,
  ) async {
    try {
      AppLogger.info('📦 Executando batch');

      final batch = _firestore.batch();
      operations(batch);
      await batch.commit();

      AppLogger.info('✅ Batch concluído');
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro no batch', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado no batch', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Batch update em múltiplos documentos
  Future<void> batchUpdate({
    required String collection,
    required List<String> docIds,
    required Map<String, dynamic> updates,
  }) async {
    await executeBatch((batch) {
      for (final docId in docIds) {
        final ref = _firestore.collection(collection).doc(docId);
        batch.update(ref, updates);
      }
    });
  }

  /// Batch delete em múltiplos documentos
  Future<void> batchDelete({
    required String collection,
    required List<String> docIds,
  }) async {
    await executeBatch((batch) {
      for (final docId in docIds) {
        final ref = _firestore.collection(collection).doc(docId);
        batch.delete(ref);
      }
    });
  }

  // ============================================
  // 🔍 Queries Complexas
  // ============================================

  /// Query com múltiplos filtros e ordenação
  Query buildQuery({
    required String collection,
    List<QueryFilter>? filters,
    List<QueryOrder>? orders,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    // Aplicar filtros
    if (filters != null) {
      for (final filter in filters) {
        query = query.where(
          filter.field,
          isEqualTo: filter.isEqualTo,
          isNotEqualTo: filter.isNotEqualTo,
          isLessThan: filter.isLessThan,
          isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
          isGreaterThan: filter.isGreaterThan,
          isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
          arrayContains: filter.arrayContains,
          arrayContainsAny: filter.arrayContainsAny,
          whereIn: filter.whereIn,
          whereNotIn: filter.whereNotIn,
          isNull: filter.isNull,
        );
      }
    }

    // Aplicar ordenação
    if (orders != null) {
      for (final order in orders) {
        query = query.orderBy(order.field, descending: order.descending);
      }
    }

    // Aplicar limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  /// Query com paginação cursor-based
  Future<QueryPage<T>> queryPaginated<T>({
    required String collection,
    required T Function(DocumentSnapshot doc) fromSnapshot,
    List<QueryFilter>? filters,
    List<QueryOrder>? orders,
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = buildQuery(
        collection: collection,
        filters: filters,
        orders: orders,
        limit: pageSize + 1, // +1 para saber se tem próxima página
      );

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;

      final hasNextPage = docs.length > pageSize;
      final items = docs
          .take(pageSize)
          .map((doc) => fromSnapshot(doc))
          .toList();

      return QueryPage(
        items: items,
        hasNextPage: hasNextPage,
        lastDocument: docs.isNotEmpty ? docs[docs.length - 1] : null,
      );
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro na query paginada', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado na query', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 📊 Aggregations
  // ============================================

  /// Conta documentos com filtros
  Future<int> count({
    required String collection,
    List<QueryFilter>? filters,
  }) async {
    try {
      final query = buildQuery(collection: collection, filters: filters);
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao contar', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Soma valores de um campo
  Future<double> sum({
    required String collection,
    required String field,
    List<QueryFilter>? filters,
  }) async {
    try {
      final query = buildQuery(collection: collection, filters: filters);
      final snapshot = await query.get();

      return snapshot.docs.fold<double>(0.0, (total, doc) {
        final value = doc.data() as Map<String, dynamic>;
        final fieldValue = value[field];
        if (fieldValue is num) {
          return total + fieldValue.toDouble();
        }
        return total;
      });
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao somar', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Calcula média de um campo
  Future<double> average({
    required String collection,
    required String field,
    List<QueryFilter>? filters,
  }) async {
    try {
      final query = buildQuery(collection: collection, filters: filters);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) return 0.0;

      final sum = snapshot.docs.fold<double>(0.0, (total, doc) {
        final value = doc.data() as Map<String, dynamic>;
        final fieldValue = value[field];
        if (fieldValue is num) {
          return total + fieldValue.toDouble();
        }
        return total;
      });

      return sum / snapshot.docs.length;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao calcular média', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🔄 Operações em Subcollections
  // ============================================

  /// Lista subcollections conhecidas de um documento
  /// Nota: listCollections() só está disponível no Admin SDK
  /// No client SDK, você precisa conhecer os nomes das subcollections
  List<String> getKnownSubcollections() {
    // Retorna subcollections conhecidas do seu schema
    return ['notes', 'history', 'attachments'];
  }

  /// Copia dados de uma subcollection
  Future<void> copySubcollection({
    required String fromCollection,
    required String fromDocId,
    required String subCollection,
    required String toCollection,
    required String toDocId,
  }) async {
    try {
      final fromRef = _firestore
          .collection(fromCollection)
          .doc(fromDocId)
          .collection(subCollection);

      final toRef = _firestore
          .collection(toCollection)
          .doc(toDocId)
          .collection(subCollection);

      final snapshot = await fromRef.get();

      await executeBatch((batch) {
        for (final doc in snapshot.docs) {
          batch.set(toRef.doc(doc.id), doc.data());
        }
      });

      AppLogger.info('✅ Subcollection copiada');
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao copiar subcollection', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🛠️ Utilitários
  // ============================================

  /// Gera um novo ID de documento
  String generateId() {
    return _firestore.collection('_').doc().id;
  }

  /// Obtém timestamp do servidor
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Incrementa um valor numérico
  FieldValue increment(num value) => FieldValue.increment(value);

  /// Remove um campo
  FieldValue get deleteField => FieldValue.delete();

  /// Une arrays
  FieldValue arrayUnion(List values) => FieldValue.arrayUnion(values);

  /// Remove de arrays
  FieldValue arrayRemove(List values) => FieldValue.arrayRemove(values);
}

// ============================================
// 📋 Classes Auxiliares
// ============================================

/// Filtro para queries
class QueryFilter {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  final bool? isNull;

  const QueryFilter({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });
}

/// Ordenação para queries
class QueryOrder {
  final String field;
  final bool descending;

  const QueryOrder({
    required this.field,
    this.descending = false,
  });
}

/// Página de resultados paginados
class QueryPage<T> {
  final List<T> items;
  final bool hasNextPage;
  final DocumentSnapshot? lastDocument;

  const QueryPage({
    required this.items,
    required this.hasNextPage,
    this.lastDocument,
  });
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

/// Provider do FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

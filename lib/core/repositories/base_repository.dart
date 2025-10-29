// lib/core/repositories/base_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// 🏗️ Base Repository - Interface abstrata para todos os repositories
/// 
/// Define operações CRUD padrão e métodos helper para Firestore.
/// Todos os repositories específicos devem estender esta classe.
abstract class BaseRepository<T> {
  /// Nome da coleção no Firestore
  String get collectionName;

  /// Referência para a coleção no Firestore
  CollectionReference get collection =>
      FirebaseFirestore.instance.collection(collectionName);

  /// Converte DocumentSnapshot para o modelo T
  T fromFirestore(DocumentSnapshot doc);

  /// Converte o modelo T para Map para Firestore
  Map<String, dynamic> toFirestore(T model);

  // ============================================
  // 📝 CREATE
  // ============================================

  /// Cria um novo documento
  Future<String> create(T model, [String? customId]) async {
    try {
      AppLogger.debug('Creating document in $collectionName');
      
      final data = toFirestore(model);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (customId != null) {
        await collection.doc(customId).set(data);
        AppLogger.info('Document created with custom ID: $customId');
        return customId;
      } else {
        final docRef = await collection.add(data);
        AppLogger.info('Document created with ID: ${docRef.id}');
        return docRef.id;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error creating document in $collectionName', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Cria múltiplos documentos em batch
  Future<void> createBatch(List<T> models) async {
    try {
      AppLogger.debug('Creating ${models.length} documents in $collectionName');
      
      final batch = FirebaseFirestore.instance.batch();
      
      for (final model in models) {
        final docRef = collection.doc();
        final data = toFirestore(model);
        data['createdAt'] = FieldValue.serverTimestamp();
        data['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(docRef, data);
      }

      await batch.commit();
      AppLogger.info('Batch create completed: ${models.length} documents');
    } catch (e, stackTrace) {
      AppLogger.error('Error in batch create', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  // ============================================
  // 📖 READ
  // ============================================

  /// Busca um documento por ID
  Future<T?> getById(String id) async {
    try {
      AppLogger.debug('Fetching document $id from $collectionName');
      
      final doc = await collection.doc(id).get();
      
      if (!doc.exists) {
        AppLogger.warning('Document $id not found in $collectionName');
        return null;
      }

      return fromFirestore(doc);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching document $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Busca todos os documentos
  Future<List<T>> getAll({
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      AppLogger.debug('Fetching all documents from $collectionName');
      
      Query query = collection;

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      final items = snapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();

      AppLogger.info('Fetched ${items.length} documents from $collectionName');
      return items;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching all documents', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Busca documentos com filtro
  Future<List<T>> getWhere(
    String field,
    dynamic value, {
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      AppLogger.debug('Querying $collectionName where $field = $value');
      
      Query query = collection.where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      final items = snapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();

      AppLogger.info('Query returned ${items.length} documents');
      return items;
    } catch (e, stackTrace) {
      AppLogger.error('Error in query', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Busca documentos com query complexa
  Future<List<T>> getWithQuery(
    Query Function(CollectionReference ref) queryBuilder, {
    int? limit,
  }) async {
    try {
      AppLogger.debug('Executing complex query on $collectionName');
      
      Query query = queryBuilder(collection);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      final items = snapshot.docs
          .map((doc) => fromFirestore(doc))
          .toList();

      AppLogger.info('Complex query returned ${items.length} documents');
      return items;
    } catch (e, stackTrace) {
      AppLogger.error('Error in complex query', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Stream de um documento
  Stream<T?> watchById(String id) {
    try {
      AppLogger.debug('Watching document $id from $collectionName');
      
      return collection.doc(id).snapshots().map((doc) {
        if (!doc.exists) return null;
        return fromFirestore(doc);
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error watching document $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Stream de todos os documentos
  Stream<List<T>> watchAll({
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      AppLogger.debug('Watching all documents from $collectionName');
      
      Query query = collection;

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error watching all documents', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Stream com filtro
  Stream<List<T>> watchWhere(
    String field,
    dynamic value, {
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      AppLogger.debug('Watching $collectionName where $field = $value');
      
      Query query = collection.where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error watching with filter', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  // ============================================
  // ✏️ UPDATE
  // ============================================

  /// Atualiza um documento completo
  Future<void> update(String id, T model) async {
    try {
      AppLogger.debug('Updating document $id in $collectionName');
      
      final data = toFirestore(model);
      data['updatedAt'] = FieldValue.serverTimestamp();

      await collection.doc(id).update(data);
      AppLogger.info('Document $id updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating document $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Atualiza campos específicos
  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    try {
      AppLogger.debug('Updating fields in document $id');
      
      fields['updatedAt'] = FieldValue.serverTimestamp();

      await collection.doc(id).update(fields);
      AppLogger.info('Fields updated in document $id');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating fields in $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Atualiza ou cria (upsert)
  Future<void> upsert(String id, T model) async {
    try {
      AppLogger.debug('Upserting document $id in $collectionName');
      
      final data = toFirestore(model);
      data['updatedAt'] = FieldValue.serverTimestamp();

      await collection.doc(id).set(
        data,
        SetOptions(merge: true),
      );
      AppLogger.info('Document $id upserted successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error upserting document $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  // ============================================
  // 🗑️ DELETE
  // ============================================

  /// Deleta um documento
  Future<void> delete(String id) async {
    try {
      AppLogger.debug('Deleting document $id from $collectionName');
      
      await collection.doc(id).delete();
      AppLogger.info('Document $id deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting document $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Soft delete (marca como deletado)
  Future<void> softDelete(String id) async {
    try {
      AppLogger.debug('Soft deleting document $id from $collectionName');
      
      await updateFields(id, {
        'deletedAt': FieldValue.serverTimestamp(),
        'isDeleted': true,
      });
      AppLogger.info('Document $id soft deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error soft deleting document $id', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Deleta múltiplos documentos
  Future<void> deleteBatch(List<String> ids) async {
    try {
      AppLogger.debug('Batch deleting ${ids.length} documents');
      
      final batch = FirebaseFirestore.instance.batch();
      
      for (final id in ids) {
        batch.delete(collection.doc(id));
      }

      await batch.commit();
      AppLogger.info('Batch delete completed: ${ids.length} documents');
    } catch (e, stackTrace) {
      AppLogger.error('Error in batch delete', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  // ============================================
  // 🔢 UTILITIES
  // ============================================

  /// Conta documentos na coleção
  Future<int> count() async {
    try {
      final snapshot = await collection.count().get();
      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      AppLogger.error('Error counting documents', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Conta documentos com filtro
  Future<int> countWhere(String field, dynamic value) async {
    try {
      final snapshot = await collection
          .where(field, isEqualTo: value)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      AppLogger.error('Error counting filtered documents', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Verifica se documento existe
  Future<bool> exists(String id) async {
    try {
      final doc = await collection.doc(id).get();
      return doc.exists;
    } catch (e, stackTrace) {
      AppLogger.error('Error checking document existence', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }

  /// Busca documentos paginados
  Future<List<T>> getPaginated({
    DocumentSnapshot? startAfter,
    int limit = 20,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      Query query = collection
          .orderBy(orderBy, descending: descending)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error in pagination', e, stackTrace);
      throw ErrorHandler.handle(e, stackTrace);
    }
  }
}

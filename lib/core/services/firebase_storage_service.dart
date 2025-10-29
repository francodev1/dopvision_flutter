// lib/core/services/firebase_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// 📦 Firebase Storage Service
/// 
/// Gerencia upload, download e exclusão de arquivos no Firebase Storage.
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  // ============================================
  // 📤 Upload de Arquivos
  // ============================================

  /// Faz upload de um arquivo
  Future<String> uploadFile({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      AppLogger.info('📤 Iniciando upload: $path');

      final ref = _storage.ref().child(path);
      
      // Configurar metadata
      final settableMetadata = SettableMetadata(
        contentType: contentType,
        customMetadata: metadata,
      );

      // Fazer upload
      final uploadTask = ref.putFile(file, settableMetadata);

      // Monitorar progresso
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
          AppLogger.debug('📊 Progresso upload: ${(progress * 100).toStringAsFixed(1)}%');
        });
      }

      // Aguardar conclusão
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('✅ Upload concluído: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro no upload', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado no upload', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Upload de imagem de perfil
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
    Function(double)? onProgress,
  }) async {
    final path = 'users/$userId/profile.jpg';
    return uploadFile(
      file: file,
      path: path,
      contentType: 'image/jpeg',
      metadata: {'type': 'profile', 'userId': userId},
      onProgress: onProgress,
    );
  }

  /// Upload de imagem de campanha
  Future<String> uploadCampaignImage({
    required File file,
    required String campaignId,
    int index = 0,
    Function(double)? onProgress,
  }) async {
    final path = 'campaigns/$campaignId/image_$index.jpg';
    return uploadFile(
      file: file,
      path: path,
      contentType: 'image/jpeg',
      metadata: {'type': 'campaign', 'campaignId': campaignId},
      onProgress: onProgress,
    );
  }

  /// Upload de múltiplos arquivos
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String basePath,
    Function(int, double)? onProgress,
  }) async {
    final urls = <String>[];

    for (var i = 0; i < files.length; i++) {
      final path = '$basePath/file_$i${_getFileExtension(files[i])}';
      
      final url = await uploadFile(
        file: files[i],
        path: path,
        onProgress: onProgress != null 
            ? (progress) => onProgress(i, progress)
            : null,
      );

      urls.add(url);
    }

    return urls;
  }

  // ============================================
  // 📥 Download de Arquivos
  // ============================================

  /// Obtém URL de download de um arquivo
  Future<String> getDownloadUrl(String path) async {
    try {
      AppLogger.info('📥 Obtendo URL: $path');
      
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      
      AppLogger.info('✅ URL obtida');
      return url;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao obter URL', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Baixa um arquivo para o dispositivo
  Future<File> downloadFile({
    required String path,
    required String localPath,
    Function(double)? onProgress,
  }) async {
    try {
      AppLogger.info('📥 Baixando arquivo: $path');

      final ref = _storage.ref().child(path);
      final file = File(localPath);

      // Criar diretório se não existir
      await file.parent.create(recursive: true);

      final downloadTask = ref.writeToFile(file);

      // Monitorar progresso
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;

      AppLogger.info('✅ Download concluído');
      return file;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro no download', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado no download', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🗑️ Exclusão de Arquivos
  // ============================================

  /// Deleta um arquivo
  Future<void> deleteFile(String path) async {
    try {
      AppLogger.info('🗑️ Deletando arquivo: $path');

      final ref = _storage.ref().child(path);
      await ref.delete();

      AppLogger.info('✅ Arquivo deletado');
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao deletar arquivo', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Deleta múltiplos arquivos
  Future<void> deleteMultipleFiles(List<String> paths) async {
    for (final path in paths) {
      try {
        await deleteFile(path);
      } catch (e) {
        AppLogger.warning('⚠️ Erro ao deletar $path: $e');
      }
    }
  }

  /// Deleta uma pasta inteira
  Future<void> deleteFolder(String folderPath) async {
    try {
      AppLogger.info('🗑️ Deletando pasta: $folderPath');

      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();

      // Deletar todos os arquivos
      for (final item in listResult.items) {
        await item.delete();
      }

      // Deletar subpastas recursivamente
      for (final prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }

      AppLogger.info('✅ Pasta deletada');
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao deletar pasta', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 📋 Listagem de Arquivos
  // ============================================

  /// Lista arquivos em uma pasta
  Future<List<String>> listFiles(String folderPath) async {
    try {
      AppLogger.info('📋 Listando arquivos: $folderPath');

      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();

      final urls = <String>[];
      for (final item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      AppLogger.info('✅ ${urls.length} arquivos listados');
      return urls;
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao listar arquivos', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Obtém metadados de um arquivo
  Future<FullMetadata> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao obter metadata', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Atualiza metadados de um arquivo
  Future<void> updateMetadata({
    required String path,
    String? contentType,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata,
      );
      await ref.updateMetadata(metadata);
      AppLogger.info('✅ Metadata atualizado');
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Erro ao atualizar metadata', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🛠️ Utilitários
  // ============================================

  /// Obtém extensão do arquivo
  String _getFileExtension(File file) {
    final path = file.path;
    return path.substring(path.lastIndexOf('.'));
  }
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

/// Provider do FirebaseStorageService
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

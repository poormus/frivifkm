

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/document.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class DocumentServices{

  final documentRef = Configuration.isProduction?FirebaseFirestore.instance.collection('documents'):FirebaseFirestore.instance.collection('documents_test');

  Future createADocument(String organizationId,String fileName,Uint8List fileBytes,String uid) async{
     String documentId=Uuid().v4().toString();
     DateTime createdAt=DateTime.now();
     String documentUrl='';
     await uploadDocument(documentId,fileBytes).then((value) => documentUrl=value);
     documentRef.doc(documentId).set({
       'documentId':documentId,
       'organizationId':organizationId,
       'documentUrl':documentUrl,
       'documentName':fileName,
       'createdAt':createdAt,
       'createdByUid':uid
     });
  }

  Future<String> uploadDocument(String documentId,Uint8List fileBytes) async{
    var reference = FirebaseStorage.instance.ref().child('uploadedDocuments').child('$documentId');
    final UploadTask uploadTask = reference.putData(fileBytes);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }


  Stream<List<Document>> getDocumentsForOrganization(String organizationId){
    return documentRef.where('organizationId',isEqualTo: organizationId).
    snapshots().map((event){
      return event.docs.map((e) {
        return Document.fromMap(e.data());
      }).toList();
    });
  }


  Future deleteDocument(String documentId) async{
      documentRef.doc(documentId).delete();
      var reference = FirebaseStorage.instance.ref().child('uploadedDocuments').child('$documentId');
      await reference.delete();
  }


}
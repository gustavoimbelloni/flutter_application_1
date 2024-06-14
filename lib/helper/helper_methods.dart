// retornar um dado formatado como uma string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  // Timestamp é o objeto que recuperamos do firebase
  // então para exibi-lo, vamos convertê-lo em uma String
  DateTime dateTime = timestamp.toDate();

  //obter ano
  String year = dateTime.year.toString();

  //obter mês
  String month = dateTime.month.toString();

  //obter dia
  String day = dateTime.day.toString();

  // dados finais formatados
  String formattedData = '$day/$month/$year';

  return formattedData;
}

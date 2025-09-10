class FileDataModel {
  String? keyName;
  String? filePath;

  FileDataModel({this.keyName, this.filePath});

  factory FileDataModel.fromJson(Map<dynamic, dynamic> json) {
    return FileDataModel(
      keyName: json['key_name'],
      filePath: json['file_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"key_name": keyName, "file_path": filePath};
  }
}

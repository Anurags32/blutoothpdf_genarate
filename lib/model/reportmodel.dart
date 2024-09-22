class ReportModel {
  String? sId;
  String? laneId;
  String? tcName;
  String? dateTime;
  String? vehNum;
  int? fare;
  int? penaltyFare;
  String? expiryDateTime;
  int? iV;

  ReportModel(
      {this.sId,
      this.laneId,
      this.tcName,
      this.dateTime,
      this.vehNum,
      this.fare,
      this.penaltyFare,
      this.expiryDateTime,
      this.iV});

  ReportModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    laneId = json['laneId'];
    tcName = json['tcName'];
    dateTime = json['dateTime'];
    vehNum = json['vehNum'];
    fare = json['fare'];
    penaltyFare = json['penaltyFare'];
    expiryDateTime = json['expiryDateTime'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['laneId'] = this.laneId;
    data['tcName'] = this.tcName;
    data['dateTime'] = this.dateTime;
    data['vehNum'] = this.vehNum;
    data['fare'] = this.fare;
    data['penaltyFare'] = this.penaltyFare;
    data['expiryDateTime'] = this.expiryDateTime;
    data['__v'] = this.iV;
    return data;
  }
}

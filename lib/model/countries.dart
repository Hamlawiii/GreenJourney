class Countries {
  List<Country>? countries;

  Countries({this.countries});

  Countries.fromJson(List<dynamic> json) {
    countries = json.map((country) => Country.fromJson(country)).toList();
  }
}

class Country {
  String? name;
  String? code;
  String? emissionsRegulations;

  Country({this.name, this.code, this.emissionsRegulations});

  Country.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    emissionsRegulations = json['emissions_regulations'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['code'] = code;
    data['emissions_regulations'] = emissionsRegulations;
    return data;
  }
}

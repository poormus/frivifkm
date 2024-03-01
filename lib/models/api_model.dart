class OrgDataModel {

  String? organisasjonsnummer;
  String? navn;
  Organisasjonsform? organisasjonsform;
  Postadresse? postadresse;
  String? registreringsdatoEnhetsregisteret;
  bool? registrertIMvaregisteret;
  Naeringskode1? naeringskode1;
  int? antallAnsatte;
  String? overordnetEnhet;
  Beliggenhetsadresse? beliggenhetsadresse;
  String? nedleggelsesdato;
  Links? lLinks;

  OrgDataModel(
      {this.organisasjonsnummer,
      this.navn,
      this.organisasjonsform,
      this.postadresse,
      this.registreringsdatoEnhetsregisteret,
      this.registrertIMvaregisteret,
      this.naeringskode1,
      this.antallAnsatte,
      this.overordnetEnhet,
      this.beliggenhetsadresse,
      this.nedleggelsesdato,
      this.lLinks});

  OrgDataModel.fromJson(Map<String, dynamic> json) {
    organisasjonsnummer = json['organisasjonsnummer'];
    navn = json['navn'];
    organisasjonsform = json['organisasjonsform'] != null
        ? new Organisasjonsform.fromJson(json['organisasjonsform'])
        : null;
    postadresse = json['postadresse'] != null
        ? new Postadresse.fromJson(json['postadresse'])
        : null;
    registreringsdatoEnhetsregisteret =
        json['registreringsdatoEnhetsregisteret'];
    registrertIMvaregisteret = json['registrertIMvaregisteret'];
    naeringskode1 = json['naeringskode1'] != null
        ? new Naeringskode1.fromJson(json['naeringskode1'])
        : null;
    antallAnsatte = json['antallAnsatte'];
    overordnetEnhet = json['overordnetEnhet'];
    beliggenhetsadresse = json['beliggenhetsadresse'] != null
        ? new Beliggenhetsadresse.fromJson(json['beliggenhetsadresse'])
        : null;
    nedleggelsesdato = json['nedleggelsesdato'];
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['organisasjonsnummer'] = this.organisasjonsnummer;
    data['navn'] = this.navn;
    if (this.organisasjonsform != null) {
      data['organisasjonsform'] = this.organisasjonsform!.toJson();
    }
    if (this.postadresse != null) {
      data['postadresse'] = this.postadresse!.toJson();
    }
    data['registreringsdatoEnhetsregisteret'] =
        this.registreringsdatoEnhetsregisteret;
    data['registrertIMvaregisteret'] = this.registrertIMvaregisteret;
    if (this.naeringskode1 != null) {
      data['naeringskode1'] = this.naeringskode1!.toJson();
    }
    data['antallAnsatte'] = this.antallAnsatte;
    data['overordnetEnhet'] = this.overordnetEnhet;
    if (this.beliggenhetsadresse != null) {
      data['beliggenhetsadresse'] = this.beliggenhetsadresse!.toJson();
    }
    data['nedleggelsesdato'] = this.nedleggelsesdato;
    if (this.lLinks != null) {
      data['_links'] = this.lLinks!.toJson();
    }
    return data;
  }
}

class Organisasjonsform {
  String? kode;
  String? beskrivelse;
  Links? lLinks;

  Organisasjonsform({this.kode, this.beskrivelse, this.lLinks});

  Organisasjonsform.fromJson(Map<String, dynamic> json) {
    kode = json['kode'];
    beskrivelse = json['beskrivelse'];
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kode'] = this.kode;
    data['beskrivelse'] = this.beskrivelse;
    if (this.lLinks != null) {
      data['_links'] = this.lLinks!.toJson();
    }
    return data;
  }
}

class Links {
  Self? self;

  Links({this.self});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? new Self.fromJson(json['self']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.self != null) {
      data['self'] = this.self!.toJson();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Postadresse {
  String? land;
  String? landkode;
  String? postnummer;
  String? poststed;
  List<String>? adresse;
  String? kommune;
  String? kommunenummer;

  Postadresse(
      {this.land,
      this.landkode,
      this.postnummer,
      this.poststed,
      this.adresse,
      this.kommune,
      this.kommunenummer});

  Postadresse.fromJson(Map<String, dynamic> json) {
    land = json['land'];
    landkode = json['landkode'];
    postnummer = json['postnummer'];
    poststed = json['poststed'];
    adresse = json['adresse'].cast<String>();
    kommune = json['kommune'];
    kommunenummer = json['kommunenummer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['land'] = this.land;
    data['landkode'] = this.landkode;
    data['postnummer'] = this.postnummer;
    data['poststed'] = this.poststed;
    data['adresse'] = this.adresse;
    data['kommune'] = this.kommune;
    data['kommunenummer'] = this.kommunenummer;
    return data;
  }
}

class Naeringskode1 {
  String? beskrivelse;
  String? kode;

  Naeringskode1({this.beskrivelse, this.kode});

  Naeringskode1.fromJson(Map<String, dynamic> json) {
    beskrivelse = json['beskrivelse'];
    kode = json['kode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['beskrivelse'] = this.beskrivelse;
    data['kode'] = this.kode;
    return data;
  }
}

class Beliggenhetsadresse {
  String? land;
  String? landkode;
  String? postnummer;
  String? poststed;
  List<String>? adresse;
  String? kommune;
  String? kommunenummer;

  Beliggenhetsadresse(
      {this.land,
      this.landkode,
      this.postnummer,
      this.poststed,
      this.adresse,
      this.kommune,
      this.kommunenummer});

  Beliggenhetsadresse.fromJson(Map<String, dynamic> json) {
    land = json['land'];
    landkode = json['landkode'];
    postnummer = json['postnummer'];
    poststed = json['poststed'];
    adresse = json['adresse'].cast<String>();
    kommune = json['kommune'];
    kommunenummer = json['kommunenummer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['land'] = this.land;
    data['landkode'] = this.landkode;
    data['postnummer'] = this.postnummer;
    data['poststed'] = this.poststed;
    data['adresse'] = this.adresse;
    data['kommune'] = this.kommune;
    data['kommunenummer'] = this.kommunenummer;
    return data;
  }
}



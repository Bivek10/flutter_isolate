class MoviesModel {
  List<Categories>? categories;

  MoviesModel({this.categories});

  MoviesModel.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? name;
  List<Videos>? videos;

  Categories({this.name, this.videos});

  Categories.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['videos'] != null) {
      videos = <Videos>[];
      json['videos'].forEach((v) {
        videos!.add(Videos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (videos != null) {
      data['videos'] = videos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Videos {
  String? description;
  List<String>? sources;
  String? subtitle;
  String? thumb;
  String? title;

  Videos(
      {this.description, this.sources, this.subtitle, this.thumb, this.title});

  Videos.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    sources = json['sources'].cast<String>();
    subtitle = json['subtitle'];
    thumb = json['thumb'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['sources'] = sources;
    data['subtitle'] = subtitle;
    data['thumb'] = thumb;
    data['title'] = title;
    return data;
  }
}

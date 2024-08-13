import 'package:cinetrack/core/utils/app_color.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final double popularity;
  final List<Genre> genres;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<SpokenLanguage> spokenLanguages;
  List<Cast> cast;
  List<Crew> crew;
  final String status;
  final String originalLanguage;
  final int budget;
  final int revenue;
  final int runtime;
  final String tagline;
  final bool adult;
  final bool video;
  final String imdbId;
  final String homepage;
  Color dominantColor;
  Color textColor;

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.popularity,
    required this.genres,
    required this.productionCompanies,
    required this.productionCountries,
    required this.spokenLanguages,
    required this.status,
    required this.originalLanguage,
    required this.budget,
    required this.revenue,
    required this.runtime,
    required this.tagline,
    required this.adult,
    required this.video,
    required this.imdbId,
    this.cast = const [],
    this.crew = const [],
    required this.homepage,
    this.dominantColor = AppColor.bg,
    this.textColor = Colors.black,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      originalTitle: json['original_title'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      genres: (json['genres'] as List<dynamic>?)
          ?.map((genre) => Genre.fromJson(genre))
          .toList() ?? [],
      productionCompanies: (json['production_companies'] as List<dynamic>?)
          ?.map((company) => ProductionCompany.fromJson(company))
          .toList() ?? [],
      productionCountries: (json['production_countries'] as List<dynamic>?)
          ?.map((country) => ProductionCountry.fromJson(country))
          .toList() ?? [],
      spokenLanguages: (json['spoken_languages'] as List<dynamic>?)
          ?.map((language) => SpokenLanguage.fromJson(language))
          .toList() ?? [],
      status: json['status'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      runtime: json['runtime'] ?? 0,
      tagline: json['tagline'] ?? '',
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
      imdbId: json['imdb_id'] ?? '',
      homepage: json['homepage'] ?? '',
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ProductionCompany {
  final int id;
  final String name;
  final String? logoPath;
  final String originCountry;

  ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'],
      name: json['name'],
      logoPath: json['logo_path'],
      originCountry: json['origin_country'],
    );
  }
}

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({required this.iso31661, required this.name});

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso31661: json['iso_3166_1'],
      name: json['name'],
    );
  }
}

class SpokenLanguage {
  final String iso6391;
  final String name;

  SpokenLanguage({required this.iso6391, required this.name});

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      iso6391: json['iso_639_1'],
      name: json['name'],
    );
  }
}


class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }
}

class Crew {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  Crew({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'],
      name: json['name'],
      job: json['job'],
      department: json['department'],
      profilePath: json['profile_path'],
    );
  }
}

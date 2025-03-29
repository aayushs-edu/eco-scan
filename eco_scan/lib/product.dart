import 'dart:convert';

class Product {
  Product({
    required this.productName,
    required this.ingredients,
    required this.nutriments,
    required this.nutriscore,
    required this.selectedImages,
    required this.servingSize,
    required this.traces,
    required this.novaGroup,
    required this.statesTags,
    required this.languagesTags,
  });

  String productName;
  List<Ingredient> ingredients;
  Nutriments nutriments;
  Nutriscore nutriscore;
  SelectedImages selectedImages;
  String servingSize;
  List<String> traces;
  String novaGroup;
  List<String> statesTags;
  List<String> languagesTags;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        productName: json["product_name"] ?? '',
        ingredients: List<Ingredient>.from(
            json["ingredients_analysis"]["en:palm-oil"]
                    ?.map((x) => Ingredient.fromJson(x)) ??
                []),
        nutriments: Nutriments.fromJson(json["nutriments"]),
        nutriscore: Nutriscore.fromJson(json["nutriscore"]["2023"]),
        selectedImages: SelectedImages.fromJson(json["selected_images"]),
        servingSize: json["serving_size"] ?? '',
        traces: List<String>.from(json["traces_tags"] ?? []),
        novaGroup: json["nova_groups_tags"]?[0] ?? '',
        statesTags: List<String>.from(json["states_tags"] ?? []),
        languagesTags: List<String>.from(json["languages_tags"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "product_name": productName,
        "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
        "nutriments": nutriments.toJson(),
        "nutriscore": nutriscore.toJson(),
        "selected_images": selectedImages.toJson(),
        "serving_size": servingSize,
        "traces_tags": List<dynamic>.from(traces.map((x) => x)),
        "nova_groups_tags": [novaGroup],
        "states_tags": List<dynamic>.from(statesTags.map((x) => x)),
        "languages_tags": List<dynamic>.from(languagesTags.map((x) => x)),
      };
}

class Ingredient {
  Ingredient({
    required this.id,
    required this.text,
    required this.fromPalmOil,
    required this.percentEstimate,
    required this.percentMax,
    required this.percentMin,
    required this.vegan,
    required this.vegetarian,
  });

  String id;
  String text;
  String fromPalmOil;
  double percentEstimate;
  double percentMax;
  double percentMin;
  String vegan;
  String vegetarian;

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json["id"] ?? '',
        text: json["text"] ?? '',
        fromPalmOil: json["from_palm_oil"] ?? '',
        percentEstimate: (json["percent_estimate"] ?? 0).toDouble(),
        percentMax: (json["percent_max"] ?? 0).toDouble(),
        percentMin: (json["percent_min"] ?? 0).toDouble(),
        vegan: json["vegan"] ?? 'unknown',
        vegetarian: json["vegetarian"] ?? 'unknown',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "from_palm_oil": fromPalmOil,
        "percent_estimate": percentEstimate,
        "percent_max": percentMax,
        "percent_min": percentMin,
        "vegan": vegan,
        "vegetarian": vegetarian,
      };
}

class Nutriments {
  Nutriments({
    required this.energy,
    required this.fat,
    required this.sugars,
    required this.proteins,
    required this.saturatedFat,
    required this.salt,
    required this.fiber,
  });

  double energy;
  double fat;
  double sugars;
  double proteins;
  double saturatedFat;
  double salt;
  double fiber;

  factory Nutriments.fromJson(Map<String, dynamic> json) => Nutriments(
        energy: (json["energy-kcal_100g"] ?? 0).toDouble(),
        fat: (json["fat_100g"] ?? 0).toDouble(),
        sugars: (json["sugars_100g"] ?? 0).toDouble(),
        proteins: (json["proteins_100g"] ?? 0).toDouble(),
        saturatedFat: (json["saturated-fat_100g"] ?? 0).toDouble(),
        salt: (json["salt_100g"] ?? 0).toDouble(),
        fiber: (json["fiber_100g"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "energy-kcal_100g": energy,
        "fat_100g": fat,
        "sugars_100g": sugars,
        "proteins_100g": proteins,
        "saturated-fat_100g": saturatedFat,
        "salt_100g": salt,
        "fiber_100g": fiber,
      };
}

class Nutriscore {
  Nutriscore({
    required this.grade,
    required this.sugars,
    required this.saturatedFat,
    required this.energy,
    required this.proteins,
    required this.fiber,
  });

  String grade;
  double sugars;
  double saturatedFat;
  double energy;
  double proteins;
  double fiber;

  factory Nutriscore.fromJson(Map<String, dynamic> json) => Nutriscore(
        grade: json["grade"] ?? 'unknown',
        sugars: (json["data"]["sugars"] ?? 0).toDouble(),
        saturatedFat: (json["data"]["saturated_fat"] ?? 0).toDouble(),
        energy: (json["data"]["energy"] ?? 0).toDouble(),
        proteins: (json["data"]["proteins"] ?? 0).toDouble(),
        fiber: (json["data"]["fiber"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "grade": grade,
        "data": {
          "sugars": sugars,
          "saturated_fat": saturatedFat,
          "energy": energy,
          "proteins": proteins,
          "fiber": fiber,
        },
      };
}

class SelectedImages {
  SelectedImages({
    required this.front,
    required this.ingredients,
    required this.nutrition,
  });

  ImageDetails front;
  ImageDetails ingredients;
  ImageDetails nutrition;

  factory SelectedImages.fromJson(Map<String, dynamic> json) => SelectedImages(
        front: ImageDetails.fromJson(json["front"]["display"]),
        ingredients: ImageDetails.fromJson(json["ingredients"]["display"]),
        nutrition: ImageDetails.fromJson(json["nutrition"]["display"]),
      );

  Map<String, dynamic> toJson() => {
        "front": front.toJson(),
        "ingredients": ingredients.toJson(),
        "nutrition": nutrition.toJson(),
      };
}

class ImageDetails {
  ImageDetails({
    required this.url,
  });

  String url;

  factory ImageDetails.fromJson(Map<String, dynamic> json) => ImageDetails(
        url: json["en"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "en": url,
      };
}

// Parse JSON to Dart object
Product parseProduct(String jsonStr) {
  final jsonData = json.decode(jsonStr);
  return Product.fromJson(jsonData['product']);
}

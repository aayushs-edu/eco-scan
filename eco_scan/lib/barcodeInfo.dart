import 'dart:convert';

// Main Response Class
class ProductResponse {
  String code;
  int total;
  int offset;
  List<BarcodeInfo> items;

  ProductResponse({
    required this.code,
    required this.total,
    required this.offset,
    required this.items,
  });

  factory ProductResponse.fromJson(String str) =>
      ProductResponse.fromMap(json.decode(str));

  factory ProductResponse.fromMap(Map<String, dynamic> json) => ProductResponse(
        code: json["code"],
        total: json["total"],
        offset: json["offset"],
        items:
            List<BarcodeInfo>.from(json["items"].map((x) => BarcodeInfo.fromMap(x))).toList(),
      );
}

// Item Class
class BarcodeInfo {
  String ean;
  String title;
  String description;
  String upc;
  String brand;
  String model;
  String color;
  String size;
  String dimension;
  String weight;
  String category;
  String currency;
  double? lowestRecordedPrice;
  double? highestRecordedPrice;
  List<String> images;
  List<Offer> offers;
  String asin;
  String elid;

  BarcodeInfo({
    required this.ean,
    required this.title,
    required this.description,
    required this.upc,
    required this.brand,
    required this.model,
    required this.color,
    required this.size,
    required this.dimension,
    required this.weight,
    required this.category,
    required this.currency,
    required this.lowestRecordedPrice,
    required this.highestRecordedPrice,
    required this.images,
    required this.offers,
    required this.asin,
    required this.elid,
  });

  factory BarcodeInfo.fromMap(Map<String, dynamic> json) => BarcodeInfo(
        ean: json["ean"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        upc: json["upc"] ?? "",
        brand: json["brand"] ?? "",
        model: json["model"] ?? "",
        color: json["color"] ?? "",
        size: json["size"] ?? "",
        dimension: json["dimension"] ?? "",
        weight: json["weight"] ?? "",
        category: json["category"] ?? "",
        currency: json["currency"] ?? "",
        lowestRecordedPrice: json["lowest_recorded_price"]?.toDouble(),
        highestRecordedPrice: json["highest_recorded_price"]?.toDouble(),
        images: json["images"] != null
            ? List<String>.from(json["images"].map((x) => x))
            : [], // Default to an empty list
        offers: json["offers"] != null
            ? List<Offer>.from(json["offers"].map((x) => Offer.fromMap(x)))
            : [], // Default to an empty list
        asin: json["asin"] ?? "",
        elid: json["elid"] ?? "",
      );
}

// Offer Class
class Offer {
  String merchant;
  String domain;
  String title;
  String currency;
  double? listPrice;
  double price;
  String shipping;
  String condition;
  String availability;
  String link;
  int updatedT;

  Offer({
    required this.merchant,
    required this.domain,
    required this.title,
    required this.currency,
    required this.listPrice,
    required this.price,
    required this.shipping,
    required this.condition,
    required this.availability,
    required this.link,
    required this.updatedT,
  });

  factory Offer.fromMap(Map<String, dynamic> json) => Offer(
        merchant: json["merchant"] ?? "",
        domain: json["domain"] ?? "",
        title: json["title"] ?? "",
        currency: json["currency"] ?? "",
        listPrice: json["list_price"] == "" || json["list_price"] == null
            ? null
            : json["list_price"].toDouble(),
        price: json["price"]?.toDouble() ?? 0.0, // Default to 0.0 if null
        shipping: json["shipping"] ?? "",
        condition: json["condition"] ?? "",
        availability: json["availability"] ?? "",
        link: json["link"] ?? "",
        updatedT: json["updated_t"] ?? 0,
      );
}

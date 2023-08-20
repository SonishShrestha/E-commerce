import 'package:flutter/src/material/card.dart';

class FakeStore {
  int id;
  String title;
  num price;
  String description;
  String category;
  String image;
  Rating rating;

  FakeStore(this.id, this.title, this.price, this.description, this.category,
      this.image, this.rating);

  factory FakeStore.fromJson(Map<String, dynamic> data) {
    return FakeStore(
        data['id'],
        data['title'],
        data['price'],
        data['description'],
        data['category'],
        data['image'],
        Rating.fromRating(data['rating']));
  }

  map(Card Function(dynamic byCategoryName) param0) {}
}

class Rating {
  num rate;
  int count;
  Rating(this.rate, this.count);

  factory Rating.fromRating(Map<String, dynamic> rateData) {
    return Rating(rateData['rate'], rateData['count']);
  }
}

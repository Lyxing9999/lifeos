enum PlaceType { home, work, school, gym, cafe, restaurant, store, other }

extension PlaceTypeX on PlaceType {
  static PlaceType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'HOME':
        return PlaceType.home;
      case 'WORK':
        return PlaceType.work;
      case 'SCHOOL':
        return PlaceType.school;
      case 'GYM':
        return PlaceType.gym;
      case 'CAFE':
        return PlaceType.cafe;
      case 'RESTAURANT':
        return PlaceType.restaurant;
      case 'STORE':
        return PlaceType.store;
      default:
        return PlaceType.other;
    }
  }

  String get apiValue {
    switch (this) {
      case PlaceType.home:
        return 'HOME';
      case PlaceType.work:
        return 'WORK';
      case PlaceType.school:
        return 'SCHOOL';
      case PlaceType.gym:
        return 'GYM';
      case PlaceType.cafe:
        return 'CAFE';
      case PlaceType.restaurant:
        return 'RESTAURANT';
      case PlaceType.store:
        return 'STORE';
      case PlaceType.other:
        return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case PlaceType.home:
        return 'Home';
      case PlaceType.work:
        return 'Work';
      case PlaceType.school:
        return 'School';
      case PlaceType.gym:
        return 'Gym';
      case PlaceType.cafe:
        return 'Cafe';
      case PlaceType.restaurant:
        return 'Restaurant';
      case PlaceType.store:
        return 'Store';
      case PlaceType.other:
        return 'Other';
    }
  }
}

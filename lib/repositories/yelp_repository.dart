import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:restaurantour/models/restaurant.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? _apiKey = dotenv.env['YELP_API_KEY'];

class YelpRepository {
  late Dio dio;

  YelpRepository({
    @visibleForTesting Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.yelp.com',
                headers: {
                  'Authorization': 'Bearer $_apiKey',
                  'Content-Type': 'application/graphql',
                },
              ),
            );

  Future<RestaurantQueryResult?> getRestaurants({int offset = 0}) async {
    try {
      final query = '''
      query getRestaurants {
        search(location: "Las Vegas", limit: 20, offset: $offset) {
          total
          business {
            id
            name
            price
            rating
            photos
            reviews {
              id
              rating
              user {
                id
                image_url
                name
              }
            }
            categories {
              title
              alias
            }
            hours {
              is_open_now
            }
            location {
              formatted_address
            }
          }
        }
      }
      ''';
      final response = await dio.post<Map<String, dynamic>>(
        '/v3/graphql',
        data: query,
      );
      return RestaurantQueryResult.fromJson(response.data!['data']['search']);
    } catch (e) {
      return null;
    }
  }

  Future<Restaurant?> getRestaurantDetail({required String id}) async {
    try {
      final query = '''
      query MyQuery {
        business(id: "$id") {
            id
            name
            price
            rating
            photos
            reviews {
              id
              rating
              user {
                id
                image_url
                name
              }
            }
            categories {
              title
              alias
            }
            hours {
              is_open_now
            }
            location {
              formatted_address
            }
          }
      }
      ''';
      final response = await dio.post<Map<String, dynamic>>(
        '/v3/graphql',
        data: query,
      );
      return Restaurant.fromJson(response.data!['data']['business']);
    } catch (e) {
      return null;
    }
  }
}

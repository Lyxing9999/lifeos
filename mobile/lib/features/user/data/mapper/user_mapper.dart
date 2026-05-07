import '../../domain/model/user.dart';
import '../dto/user_response_dto.dart';

class UserMapper {
  const UserMapper();

  AppUser toDomain(UserResponseDto dto) {
    return AppUser(
      id: dto.id ?? '',
      name: dto.name ?? '',
      email: dto.email ?? '',
      timezone: dto.timezone ?? '',
      locale: dto.locale ?? '',
    );
  }
}

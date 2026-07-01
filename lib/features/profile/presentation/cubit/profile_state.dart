

class ProfileState {
  const ProfileState({
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.profileData,
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final Map<String, dynamic>? profileData;

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      isSaving: false,
      errorMessage: null,
      profileData: null,
    );
  }

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    Map<String, dynamic>? profileData,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      profileData: profileData ?? this.profileData,
    );
  }
}

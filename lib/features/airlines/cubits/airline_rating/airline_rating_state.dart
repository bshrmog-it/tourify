sealed class AirlineRatingState {
  const AirlineRatingState();
}

class AirlineRatingInitial extends AirlineRatingState {
  const AirlineRatingInitial();
}

class AirlineRatingLoading extends AirlineRatingState {
  const AirlineRatingLoading();
}

class AirlineRatingSuccess extends AirlineRatingState {
  final int rating;

  const AirlineRatingSuccess(this.rating);
}

class AirlineRatingError extends AirlineRatingState {
  final String message;

  const AirlineRatingError(this.message);
}

import 'package:tourify/features/airlines/models/airline_model.dart';

sealed class AirlinesState {
  const AirlinesState();
}

class AirlinesInitial extends AirlinesState {
  const AirlinesInitial();
}

class AirlinesLoading extends AirlinesState {
  const AirlinesLoading();
}

class AirlinesLoaded extends AirlinesState {
  final List<AirlineModel> airlines;

  const AirlinesLoaded(this.airlines);
}

class AirlinesError extends AirlinesState {
  final String message;

  const AirlinesError(this.message);
}

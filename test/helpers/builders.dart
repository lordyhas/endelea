import 'package:endelea/data/database.dart';

final _date = DateTime.utc(2026, 11, 2, 18);

Exercise exercise(
  String id, {
  String name = 'Exercise',
  String? builtInKey,
  String muscleGroup = 'chest',
  String equipment = 'barbell',
  String trackingType = 'weight_reps',
  bool isCustom = true,
}) {
  return Exercise(
    id: id,
    createdAt: _date,
    updatedAt: _date,
    deleted: false,
    lastModifiedBy: 'device-a',
    name: name,
    builtInKey: builtInKey,
    muscleGroup: muscleGroup,
    equipment: equipment,
    trackingType: trackingType,
    isCustom: isCustom,
  );
}

Program program(String id, {String name = 'PPL', bool isActive = false}) {
  return Program(
    id: id,
    createdAt: _date,
    updatedAt: _date,
    deleted: false,
    lastModifiedBy: 'device-a',
    name: name,
    isActive: isActive,
  );
}

ProgramDay programDay(String id, {String programId = 'p1', int order = 10}) {
  return ProgramDay(
    id: id,
    createdAt: _date,
    updatedAt: _date,
    deleted: false,
    lastModifiedBy: 'device-a',
    programId: programId,
    name: 'Day $id',
    orderIndex: order,
  );
}

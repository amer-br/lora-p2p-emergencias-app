// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entidades.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIncidenteEntityCollection on Isar {
  IsarCollection<IncidenteEntity> get incidenteEntitys => this.collection();
}

const IncidenteEntitySchema = CollectionSchema(
  name: r'IncidenteEntity',
  id: 1802027591131053600,
  properties: {
    r'estadoEnvio': PropertySchema(
      id: 0,
      name: r'estadoEnvio',
      type: IsarType.int,
      enumMap: _IncidenteEntityestadoEnvioEnumValueMap,
    ),
    r'horaEmisor': PropertySchema(
      id: 1,
      name: r'horaEmisor',
      type: IsarType.long,
    ),
    r'horaRecepcionLocal': PropertySchema(
      id: 2,
      name: r'horaRecepcionLocal',
      type: IsarType.dateTime,
    ),
    r'lat': PropertySchema(id: 3, name: r'lat', type: IsarType.double),
    r'lon': PropertySchema(id: 4, name: r'lon', type: IsarType.double),
    r'origen': PropertySchema(
      id: 5,
      name: r'origen',
      type: IsarType.byte,
      enumMap: _IncidenteEntityorigenEnumValueMap,
    ),
    r'senderId': PropertySchema(id: 6, name: r'senderId', type: IsarType.long),
    r'texto': PropertySchema(id: 7, name: r'texto', type: IsarType.string),
    r'tipo': PropertySchema(id: 8, name: r'tipo', type: IsarType.long),
  },

  estimateSize: _incidenteEntityEstimateSize,
  serialize: _incidenteEntitySerialize,
  deserialize: _incidenteEntityDeserialize,
  deserializeProp: _incidenteEntityDeserializeProp,
  idName: r'msgId',
  indexes: {
    r'horaRecepcionLocal': IndexSchema(
      id: -6938150827591640520,
      name: r'horaRecepcionLocal',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'horaRecepcionLocal',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _incidenteEntityGetId,
  getLinks: _incidenteEntityGetLinks,
  attach: _incidenteEntityAttach,
  version: '3.3.1',
);

int _incidenteEntityEstimateSize(
  IncidenteEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.texto.length * 3;
  return bytesCount;
}

void _incidenteEntitySerialize(
  IncidenteEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeInt(offsets[0], object.estadoEnvio?.index);
  writer.writeLong(offsets[1], object.horaEmisor);
  writer.writeDateTime(offsets[2], object.horaRecepcionLocal);
  writer.writeDouble(offsets[3], object.lat);
  writer.writeDouble(offsets[4], object.lon);
  writer.writeByte(offsets[5], object.origen.index);
  writer.writeLong(offsets[6], object.senderId);
  writer.writeString(offsets[7], object.texto);
  writer.writeLong(offsets[8], object.tipo);
}

IncidenteEntity _incidenteEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IncidenteEntity();
  object.estadoEnvio =
      _IncidenteEntityestadoEnvioValueEnumMap[reader.readIntOrNull(offsets[0])];
  object.horaEmisor = reader.readLong(offsets[1]);
  object.horaRecepcionLocal = reader.readDateTime(offsets[2]);
  object.lat = reader.readDoubleOrNull(offsets[3]);
  object.lon = reader.readDoubleOrNull(offsets[4]);
  object.msgId = id;
  object.origen =
      _IncidenteEntityorigenValueEnumMap[reader.readByteOrNull(offsets[5])] ??
      Origen.propio;
  object.senderId = reader.readLong(offsets[6]);
  object.texto = reader.readString(offsets[7]);
  object.tipo = reader.readLong(offsets[8]);
  return object;
}

P _incidenteEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_IncidenteEntityestadoEnvioValueEnumMap[reader.readIntOrNull(
            offset,
          )])
          as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (_IncidenteEntityorigenValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              Origen.propio)
          as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IncidenteEntityestadoEnvioEnumValueMap = {
  'pendiente': 0,
  'enviado': 1,
  'error': 2,
};
const _IncidenteEntityestadoEnvioValueEnumMap = {
  0: EstadoEnvio.pendiente,
  1: EstadoEnvio.enviado,
  2: EstadoEnvio.error,
};
const _IncidenteEntityorigenEnumValueMap = {'propio': 0, 'recibido': 1};
const _IncidenteEntityorigenValueEnumMap = {
  0: Origen.propio,
  1: Origen.recibido,
};

Id _incidenteEntityGetId(IncidenteEntity object) {
  return object.msgId;
}

List<IsarLinkBase<dynamic>> _incidenteEntityGetLinks(IncidenteEntity object) {
  return [];
}

void _incidenteEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  IncidenteEntity object,
) {
  object.msgId = id;
}

extension IncidenteEntityQueryWhereSort
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QWhere> {
  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhere> anyMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhere>
  anyHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'horaRecepcionLocal'),
      );
    });
  }
}

extension IncidenteEntityQueryWhere
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QWhereClause> {
  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  msgIdEqualTo(Id msgId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: msgId, upper: msgId),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  msgIdNotEqualTo(Id msgId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: msgId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: msgId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: msgId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: msgId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  msgIdGreaterThan(Id msgId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: msgId, includeLower: include),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  msgIdLessThan(Id msgId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: msgId, includeUpper: include),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  msgIdBetween(
    Id lowerMsgId,
    Id upperMsgId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerMsgId,
          includeLower: includeLower,
          upper: upperMsgId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  horaRecepcionLocalEqualTo(DateTime horaRecepcionLocal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'horaRecepcionLocal',
          value: [horaRecepcionLocal],
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  horaRecepcionLocalNotEqualTo(DateTime horaRecepcionLocal) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [],
                upper: [horaRecepcionLocal],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [horaRecepcionLocal],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [horaRecepcionLocal],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [],
                upper: [horaRecepcionLocal],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  horaRecepcionLocalGreaterThan(
    DateTime horaRecepcionLocal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'horaRecepcionLocal',
          lower: [horaRecepcionLocal],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  horaRecepcionLocalLessThan(
    DateTime horaRecepcionLocal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'horaRecepcionLocal',
          lower: [],
          upper: [horaRecepcionLocal],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterWhereClause>
  horaRecepcionLocalBetween(
    DateTime lowerHoraRecepcionLocal,
    DateTime upperHoraRecepcionLocal, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'horaRecepcionLocal',
          lower: [lowerHoraRecepcionLocal],
          includeLower: includeLower,
          upper: [upperHoraRecepcionLocal],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IncidenteEntityQueryFilter
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QFilterCondition> {
  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  estadoEnvioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'estadoEnvio'),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  estadoEnvioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'estadoEnvio'),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  estadoEnvioEqualTo(EstadoEnvio? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'estadoEnvio', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  estadoEnvioGreaterThan(EstadoEnvio? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estadoEnvio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  estadoEnvioLessThan(EstadoEnvio? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estadoEnvio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  estadoEnvioBetween(
    EstadoEnvio? lower,
    EstadoEnvio? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estadoEnvio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaEmisorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'horaEmisor', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaEmisorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'horaEmisor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaEmisorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'horaEmisor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaEmisorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'horaEmisor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaRecepcionLocalEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'horaRecepcionLocal', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaRecepcionLocalGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'horaRecepcionLocal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaRecepcionLocalLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'horaRecepcionLocal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  horaRecepcionLocalBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'horaRecepcionLocal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  latIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lat'),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  latIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lat'),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  latEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lat',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  latGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lat',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  latLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lat',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  latBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  lonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lon'),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  lonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lon'),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  lonEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lon',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  lonGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lon',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  lonLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lon',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  lonBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lon',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  msgIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'msgId', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  msgIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'msgId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  msgIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'msgId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  msgIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'msgId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  origenEqualTo(Origen value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'origen', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  origenGreaterThan(Origen value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'origen',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  origenLessThan(Origen value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'origen',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  origenBetween(
    Origen lower,
    Origen upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'origen',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  senderIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  senderIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'senderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  senderIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'senderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  senderIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'senderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'texto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'texto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'texto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'texto',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'texto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'texto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'texto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'texto',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'texto', value: ''),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  textoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'texto', value: ''),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  tipoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipo', value: value),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  tipoGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipo',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  tipoLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipo',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterFilterCondition>
  tipoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IncidenteEntityQueryObject
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QFilterCondition> {}

extension IncidenteEntityQueryLinks
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QFilterCondition> {}

extension IncidenteEntityQuerySortBy
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QSortBy> {
  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByEstadoEnvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByEstadoEnvioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByHoraEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByHoraEmisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByHoraRecepcionLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByLon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByLonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByOrigen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByOrigenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByTexto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'texto', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByTextoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'texto', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> sortByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  sortByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }
}

extension IncidenteEntityQuerySortThenBy
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QSortThenBy> {
  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByEstadoEnvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByEstadoEnvioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByHoraEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByHoraEmisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByHoraRecepcionLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByLon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByLonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByMsgIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByOrigen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByOrigenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByTexto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'texto', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByTextoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'texto', Sort.desc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy> thenByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QAfterSortBy>
  thenByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }
}

extension IncidenteEntityQueryWhereDistinct
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct> {
  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct>
  distinctByEstadoEnvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estadoEnvio');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct>
  distinctByHoraEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'horaEmisor');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct>
  distinctByHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'horaRecepcionLocal');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct> distinctByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lat');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct> distinctByLon() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lon');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct> distinctByOrigen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origen');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct>
  distinctBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId');
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct> distinctByTexto({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'texto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncidenteEntity, IncidenteEntity, QDistinct> distinctByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipo');
    });
  }
}

extension IncidenteEntityQueryProperty
    on QueryBuilder<IncidenteEntity, IncidenteEntity, QQueryProperty> {
  QueryBuilder<IncidenteEntity, int, QQueryOperations> msgIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'msgId');
    });
  }

  QueryBuilder<IncidenteEntity, EstadoEnvio?, QQueryOperations>
  estadoEnvioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estadoEnvio');
    });
  }

  QueryBuilder<IncidenteEntity, int, QQueryOperations> horaEmisorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'horaEmisor');
    });
  }

  QueryBuilder<IncidenteEntity, DateTime, QQueryOperations>
  horaRecepcionLocalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'horaRecepcionLocal');
    });
  }

  QueryBuilder<IncidenteEntity, double?, QQueryOperations> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lat');
    });
  }

  QueryBuilder<IncidenteEntity, double?, QQueryOperations> lonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lon');
    });
  }

  QueryBuilder<IncidenteEntity, Origen, QQueryOperations> origenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origen');
    });
  }

  QueryBuilder<IncidenteEntity, int, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<IncidenteEntity, String, QQueryOperations> textoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'texto');
    });
  }

  QueryBuilder<IncidenteEntity, int, QQueryOperations> tipoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipo');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSafetyCheckEntityCollection on Isar {
  IsarCollection<SafetyCheckEntity> get safetyCheckEntitys => this.collection();
}

const SafetyCheckEntitySchema = CollectionSchema(
  name: r'SafetyCheckEntity',
  id: -5001443592684859508,
  properties: {
    r'estado': PropertySchema(id: 0, name: r'estado', type: IsarType.long),
    r'estadoEnvio': PropertySchema(
      id: 1,
      name: r'estadoEnvio',
      type: IsarType.int,
      enumMap: _SafetyCheckEntityestadoEnvioEnumValueMap,
    ),
    r'horaEmisor': PropertySchema(
      id: 2,
      name: r'horaEmisor',
      type: IsarType.long,
    ),
    r'horaRecepcionLocal': PropertySchema(
      id: 3,
      name: r'horaRecepcionLocal',
      type: IsarType.dateTime,
    ),
    r'origen': PropertySchema(
      id: 4,
      name: r'origen',
      type: IsarType.byte,
      enumMap: _SafetyCheckEntityorigenEnumValueMap,
    ),
    r'senderId': PropertySchema(id: 5, name: r'senderId', type: IsarType.long),
  },

  estimateSize: _safetyCheckEntityEstimateSize,
  serialize: _safetyCheckEntitySerialize,
  deserialize: _safetyCheckEntityDeserialize,
  deserializeProp: _safetyCheckEntityDeserializeProp,
  idName: r'msgId',
  indexes: {
    r'senderId': IndexSchema(
      id: -1619654757968658561,
      name: r'senderId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'senderId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'horaRecepcionLocal': IndexSchema(
      id: -6938150827591640520,
      name: r'horaRecepcionLocal',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'horaRecepcionLocal',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _safetyCheckEntityGetId,
  getLinks: _safetyCheckEntityGetLinks,
  attach: _safetyCheckEntityAttach,
  version: '3.3.1',
);

int _safetyCheckEntityEstimateSize(
  SafetyCheckEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _safetyCheckEntitySerialize(
  SafetyCheckEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.estado);
  writer.writeInt(offsets[1], object.estadoEnvio?.index);
  writer.writeLong(offsets[2], object.horaEmisor);
  writer.writeDateTime(offsets[3], object.horaRecepcionLocal);
  writer.writeByte(offsets[4], object.origen.index);
  writer.writeLong(offsets[5], object.senderId);
}

SafetyCheckEntity _safetyCheckEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SafetyCheckEntity();
  object.estado = reader.readLong(offsets[0]);
  object.estadoEnvio =
      _SafetyCheckEntityestadoEnvioValueEnumMap[reader.readIntOrNull(
        offsets[1],
      )];
  object.horaEmisor = reader.readLong(offsets[2]);
  object.horaRecepcionLocal = reader.readDateTime(offsets[3]);
  object.msgId = id;
  object.origen =
      _SafetyCheckEntityorigenValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      Origen.propio;
  object.senderId = reader.readLong(offsets[5]);
  return object;
}

P _safetyCheckEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (_SafetyCheckEntityestadoEnvioValueEnumMap[reader.readIntOrNull(
            offset,
          )])
          as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (_SafetyCheckEntityorigenValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              Origen.propio)
          as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SafetyCheckEntityestadoEnvioEnumValueMap = {
  'pendiente': 0,
  'enviado': 1,
  'error': 2,
};
const _SafetyCheckEntityestadoEnvioValueEnumMap = {
  0: EstadoEnvio.pendiente,
  1: EstadoEnvio.enviado,
  2: EstadoEnvio.error,
};
const _SafetyCheckEntityorigenEnumValueMap = {'propio': 0, 'recibido': 1};
const _SafetyCheckEntityorigenValueEnumMap = {
  0: Origen.propio,
  1: Origen.recibido,
};

Id _safetyCheckEntityGetId(SafetyCheckEntity object) {
  return object.msgId;
}

List<IsarLinkBase<dynamic>> _safetyCheckEntityGetLinks(
  SafetyCheckEntity object,
) {
  return [];
}

void _safetyCheckEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SafetyCheckEntity object,
) {
  object.msgId = id;
}

extension SafetyCheckEntityQueryWhereSort
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QWhere> {
  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhere> anyMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhere>
  anySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'senderId'),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhere>
  anyHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'horaRecepcionLocal'),
      );
    });
  }
}

extension SafetyCheckEntityQueryWhere
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QWhereClause> {
  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  msgIdEqualTo(Id msgId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: msgId, upper: msgId),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  msgIdNotEqualTo(Id msgId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: msgId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: msgId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: msgId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: msgId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  msgIdGreaterThan(Id msgId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: msgId, includeLower: include),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  msgIdLessThan(Id msgId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: msgId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  msgIdBetween(
    Id lowerMsgId,
    Id upperMsgId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerMsgId,
          includeLower: includeLower,
          upper: upperMsgId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  senderIdEqualTo(int senderId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'senderId', value: [senderId]),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  senderIdNotEqualTo(int senderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [],
                upper: [senderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [senderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [senderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [],
                upper: [senderId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  senderIdGreaterThan(int senderId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'senderId',
          lower: [senderId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  senderIdLessThan(int senderId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'senderId',
          lower: [],
          upper: [senderId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  senderIdBetween(
    int lowerSenderId,
    int upperSenderId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'senderId',
          lower: [lowerSenderId],
          includeLower: includeLower,
          upper: [upperSenderId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  horaRecepcionLocalEqualTo(DateTime horaRecepcionLocal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'horaRecepcionLocal',
          value: [horaRecepcionLocal],
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  horaRecepcionLocalNotEqualTo(DateTime horaRecepcionLocal) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [],
                upper: [horaRecepcionLocal],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [horaRecepcionLocal],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [horaRecepcionLocal],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'horaRecepcionLocal',
                lower: [],
                upper: [horaRecepcionLocal],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  horaRecepcionLocalGreaterThan(
    DateTime horaRecepcionLocal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'horaRecepcionLocal',
          lower: [horaRecepcionLocal],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  horaRecepcionLocalLessThan(
    DateTime horaRecepcionLocal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'horaRecepcionLocal',
          lower: [],
          upper: [horaRecepcionLocal],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterWhereClause>
  horaRecepcionLocalBetween(
    DateTime lowerHoraRecepcionLocal,
    DateTime upperHoraRecepcionLocal, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'horaRecepcionLocal',
          lower: [lowerHoraRecepcionLocal],
          includeLower: includeLower,
          upper: [upperHoraRecepcionLocal],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SafetyCheckEntityQueryFilter
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QFilterCondition> {
  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'estado', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estado',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estado',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estado',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEnvioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'estadoEnvio'),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEnvioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'estadoEnvio'),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEnvioEqualTo(EstadoEnvio? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'estadoEnvio', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEnvioGreaterThan(EstadoEnvio? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estadoEnvio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEnvioLessThan(EstadoEnvio? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estadoEnvio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  estadoEnvioBetween(
    EstadoEnvio? lower,
    EstadoEnvio? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estadoEnvio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaEmisorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'horaEmisor', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaEmisorGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'horaEmisor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaEmisorLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'horaEmisor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaEmisorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'horaEmisor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaRecepcionLocalEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'horaRecepcionLocal', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaRecepcionLocalGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'horaRecepcionLocal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaRecepcionLocalLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'horaRecepcionLocal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  horaRecepcionLocalBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'horaRecepcionLocal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  msgIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'msgId', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  msgIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'msgId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  msgIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'msgId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  msgIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'msgId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  origenEqualTo(Origen value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'origen', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  origenGreaterThan(Origen value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'origen',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  origenLessThan(Origen value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'origen',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  origenBetween(
    Origen lower,
    Origen upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'origen',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  senderIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: value),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  senderIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'senderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  senderIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'senderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterFilterCondition>
  senderIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'senderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SafetyCheckEntityQueryObject
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QFilterCondition> {}

extension SafetyCheckEntityQueryLinks
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QFilterCondition> {}

extension SafetyCheckEntityQuerySortBy
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QSortBy> {
  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByEstadoEnvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByEstadoEnvioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByHoraEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByHoraEmisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByHoraRecepcionLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByOrigen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortByOrigenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }
}

extension SafetyCheckEntityQuerySortThenBy
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QSortThenBy> {
  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByEstadoEnvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByEstadoEnvioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estadoEnvio', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByHoraEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByHoraEmisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaEmisor', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByHoraRecepcionLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'horaRecepcionLocal', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByMsgIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByOrigen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenByOrigenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origen', Sort.desc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }
}

extension SafetyCheckEntityQueryWhereDistinct
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct> {
  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct>
  distinctByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado');
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct>
  distinctByEstadoEnvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estadoEnvio');
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct>
  distinctByHoraEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'horaEmisor');
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct>
  distinctByHoraRecepcionLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'horaRecepcionLocal');
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct>
  distinctByOrigen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origen');
    });
  }

  QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QDistinct>
  distinctBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId');
    });
  }
}

extension SafetyCheckEntityQueryProperty
    on QueryBuilder<SafetyCheckEntity, SafetyCheckEntity, QQueryProperty> {
  QueryBuilder<SafetyCheckEntity, int, QQueryOperations> msgIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'msgId');
    });
  }

  QueryBuilder<SafetyCheckEntity, int, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<SafetyCheckEntity, EstadoEnvio?, QQueryOperations>
  estadoEnvioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estadoEnvio');
    });
  }

  QueryBuilder<SafetyCheckEntity, int, QQueryOperations> horaEmisorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'horaEmisor');
    });
  }

  QueryBuilder<SafetyCheckEntity, DateTime, QQueryOperations>
  horaRecepcionLocalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'horaRecepcionLocal');
    });
  }

  QueryBuilder<SafetyCheckEntity, Origen, QQueryOperations> origenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origen');
    });
  }

  QueryBuilder<SafetyCheckEntity, int, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecursoEntityCollection on Isar {
  IsarCollection<RecursoEntity> get recursoEntitys => this.collection();
}

const RecursoEntitySchema = CollectionSchema(
  name: r'RecursoEntity',
  id: -4366500660776730344,
  properties: {
    r'descripcion': PropertySchema(
      id: 0,
      name: r'descripcion',
      type: IsarType.string,
    ),
    r'fechaActualizacion': PropertySchema(
      id: 1,
      name: r'fechaActualizacion',
      type: IsarType.dateTime,
    ),
    r'lat': PropertySchema(id: 2, name: r'lat', type: IsarType.double),
    r'lon': PropertySchema(id: 3, name: r'lon', type: IsarType.double),
    r'nombre': PropertySchema(id: 4, name: r'nombre', type: IsarType.string),
    r'tipo': PropertySchema(
      id: 5,
      name: r'tipo',
      type: IsarType.byte,
      enumMap: _RecursoEntitytipoEnumValueMap,
    ),
  },

  estimateSize: _recursoEntityEstimateSize,
  serialize: _recursoEntitySerialize,
  deserialize: _recursoEntityDeserialize,
  deserializeProp: _recursoEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _recursoEntityGetId,
  getLinks: _recursoEntityGetLinks,
  attach: _recursoEntityAttach,
  version: '3.3.1',
);

int _recursoEntityEstimateSize(
  RecursoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.descripcion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  return bytesCount;
}

void _recursoEntitySerialize(
  RecursoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.descripcion);
  writer.writeDateTime(offsets[1], object.fechaActualizacion);
  writer.writeDouble(offsets[2], object.lat);
  writer.writeDouble(offsets[3], object.lon);
  writer.writeString(offsets[4], object.nombre);
  writer.writeByte(offsets[5], object.tipo.index);
}

RecursoEntity _recursoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecursoEntity();
  object.descripcion = reader.readStringOrNull(offsets[0]);
  object.fechaActualizacion = reader.readDateTime(offsets[1]);
  object.id = id;
  object.lat = reader.readDouble(offsets[2]);
  object.lon = reader.readDouble(offsets[3]);
  object.nombre = reader.readString(offsets[4]);
  object.tipo =
      _RecursoEntitytipoValueEnumMap[reader.readByteOrNull(offsets[5])] ??
      TipoRecurso.puntoReunion;
  return object;
}

P _recursoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_RecursoEntitytipoValueEnumMap[reader.readByteOrNull(offset)] ??
              TipoRecurso.puntoReunion)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecursoEntitytipoEnumValueMap = {
  'puntoReunion': 0,
  'refugio': 1,
  'salidaEvacuacion': 2,
  'botiquin': 3,
  'dea': 4,
};
const _RecursoEntitytipoValueEnumMap = {
  0: TipoRecurso.puntoReunion,
  1: TipoRecurso.refugio,
  2: TipoRecurso.salidaEvacuacion,
  3: TipoRecurso.botiquin,
  4: TipoRecurso.dea,
};

Id _recursoEntityGetId(RecursoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recursoEntityGetLinks(RecursoEntity object) {
  return [];
}

void _recursoEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  RecursoEntity object,
) {
  object.id = id;
}

extension RecursoEntityQueryWhereSort
    on QueryBuilder<RecursoEntity, RecursoEntity, QWhere> {
  QueryBuilder<RecursoEntity, RecursoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecursoEntityQueryWhere
    on QueryBuilder<RecursoEntity, RecursoEntity, QWhereClause> {
  QueryBuilder<RecursoEntity, RecursoEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecursoEntityQueryFilter
    on QueryBuilder<RecursoEntity, RecursoEntity, QFilterCondition> {
  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'descripcion'),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'descripcion'),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'descripcion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'descripcion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'descripcion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'descripcion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'descripcion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'descripcion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'descripcion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'descripcion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'descripcion', value: ''),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  descripcionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'descripcion', value: ''),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  fechaActualizacionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fechaActualizacion', value: value),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  fechaActualizacionGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fechaActualizacion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  fechaActualizacionLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fechaActualizacion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  fechaActualizacionBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fechaActualizacion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> latEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lat',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  latGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lat',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> latLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lat',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> latBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> lonEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lon',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  lonGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lon',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> lonLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lon',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> lonBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lon',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nombre',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nombre',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nombre',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nombre',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nombre',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nombre',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nombre',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nombre',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nombre', value: ''),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nombre', value: ''),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> tipoEqualTo(
    TipoRecurso value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipo', value: value),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  tipoGreaterThan(TipoRecurso value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipo',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition>
  tipoLessThan(TipoRecurso value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipo',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterFilterCondition> tipoBetween(
    TipoRecurso lower,
    TipoRecurso upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecursoEntityQueryObject
    on QueryBuilder<RecursoEntity, RecursoEntity, QFilterCondition> {}

extension RecursoEntityQueryLinks
    on QueryBuilder<RecursoEntity, RecursoEntity, QFilterCondition> {}

extension RecursoEntityQuerySortBy
    on QueryBuilder<RecursoEntity, RecursoEntity, QSortBy> {
  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy>
  sortByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy>
  sortByFechaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy>
  sortByFechaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByLon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByLonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> sortByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }
}

extension RecursoEntityQuerySortThenBy
    on QueryBuilder<RecursoEntity, RecursoEntity, QSortThenBy> {
  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByDescripcion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy>
  thenByDescripcionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descripcion', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy>
  thenByFechaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaActualizacion', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy>
  thenByFechaActualizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaActualizacion', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByLon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByLonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lon', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QAfterSortBy> thenByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }
}

extension RecursoEntityQueryWhereDistinct
    on QueryBuilder<RecursoEntity, RecursoEntity, QDistinct> {
  QueryBuilder<RecursoEntity, RecursoEntity, QDistinct> distinctByDescripcion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descripcion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QDistinct>
  distinctByFechaActualizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaActualizacion');
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QDistinct> distinctByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lat');
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QDistinct> distinctByLon() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lon');
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QDistinct> distinctByNombre({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecursoEntity, RecursoEntity, QDistinct> distinctByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipo');
    });
  }
}

extension RecursoEntityQueryProperty
    on QueryBuilder<RecursoEntity, RecursoEntity, QQueryProperty> {
  QueryBuilder<RecursoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecursoEntity, String?, QQueryOperations> descripcionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descripcion');
    });
  }

  QueryBuilder<RecursoEntity, DateTime, QQueryOperations>
  fechaActualizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaActualizacion');
    });
  }

  QueryBuilder<RecursoEntity, double, QQueryOperations> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lat');
    });
  }

  QueryBuilder<RecursoEntity, double, QQueryOperations> lonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lon');
    });
  }

  QueryBuilder<RecursoEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<RecursoEntity, TipoRecurso, QQueryOperations> tipoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipo');
    });
  }
}

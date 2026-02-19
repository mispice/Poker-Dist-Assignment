//
//  Generated code. Do not modify.
//  source: poker.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class HandRequest extends $pb.GeneratedMessage {
  factory HandRequest({
    $core.Iterable<$core.String>? holeCards,
    $core.Iterable<$core.String>? communityCards,
  }) {
    final $result = create();
    if (holeCards != null) {
      $result.holeCards.addAll(holeCards);
    }
    if (communityCards != null) {
      $result.communityCards.addAll(communityCards);
    }
    return $result;
  }
  HandRequest._() : super();
  factory HandRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HandRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HandRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'poker'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'holeCards')
    ..pPS(2, _omitFieldNames ? '' : 'communityCards')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HandRequest clone() => HandRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HandRequest copyWith(void Function(HandRequest) updates) => super.copyWith((message) => updates(message as HandRequest)) as HandRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HandRequest create() => HandRequest._();
  HandRequest createEmptyInstance() => create();
  static $pb.PbList<HandRequest> createRepeated() => $pb.PbList<HandRequest>();
  @$core.pragma('dart2js:noInline')
  static HandRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandRequest>(create);
  static HandRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get holeCards => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get communityCards => $_getList(1);
}

class HandResponse extends $pb.GeneratedMessage {
  factory HandResponse({
    $core.String? bestHandName,
    $core.int? handRankValue,
    $core.Iterable<$core.String>? bestCards,
  }) {
    final $result = create();
    if (bestHandName != null) {
      $result.bestHandName = bestHandName;
    }
    if (handRankValue != null) {
      $result.handRankValue = handRankValue;
    }
    if (bestCards != null) {
      $result.bestCards.addAll(bestCards);
    }
    return $result;
  }
  HandResponse._() : super();
  factory HandResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HandResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HandResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'poker'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'bestHandName')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'handRankValue', $pb.PbFieldType.O3)
    ..pPS(3, _omitFieldNames ? '' : 'bestCards')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HandResponse clone() => HandResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HandResponse copyWith(void Function(HandResponse) updates) => super.copyWith((message) => updates(message as HandResponse)) as HandResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HandResponse create() => HandResponse._();
  HandResponse createEmptyInstance() => create();
  static $pb.PbList<HandResponse> createRepeated() => $pb.PbList<HandResponse>();
  @$core.pragma('dart2js:noInline')
  static HandResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandResponse>(create);
  static HandResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bestHandName => $_getSZ(0);
  @$pb.TagNumber(1)
  set bestHandName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBestHandName() => $_has(0);
  @$pb.TagNumber(1)
  void clearBestHandName() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get handRankValue => $_getIZ(1);
  @$pb.TagNumber(2)
  set handRankValue($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHandRankValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearHandRankValue() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get bestCards => $_getList(2);
}

class CompareRequest extends $pb.GeneratedMessage {
  factory CompareRequest({
    HandRequest? hand1,
    HandRequest? hand2,
  }) {
    final $result = create();
    if (hand1 != null) {
      $result.hand1 = hand1;
    }
    if (hand2 != null) {
      $result.hand2 = hand2;
    }
    return $result;
  }
  CompareRequest._() : super();
  factory CompareRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CompareRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CompareRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'poker'), createEmptyInstance: create)
    ..aOM<HandRequest>(1, _omitFieldNames ? '' : 'hand1', subBuilder: HandRequest.create)
    ..aOM<HandRequest>(2, _omitFieldNames ? '' : 'hand2', subBuilder: HandRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CompareRequest clone() => CompareRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CompareRequest copyWith(void Function(CompareRequest) updates) => super.copyWith((message) => updates(message as CompareRequest)) as CompareRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompareRequest create() => CompareRequest._();
  CompareRequest createEmptyInstance() => create();
  static $pb.PbList<CompareRequest> createRepeated() => $pb.PbList<CompareRequest>();
  @$core.pragma('dart2js:noInline')
  static CompareRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CompareRequest>(create);
  static CompareRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HandRequest get hand1 => $_getN(0);
  @$pb.TagNumber(1)
  set hand1(HandRequest v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHand1() => $_has(0);
  @$pb.TagNumber(1)
  void clearHand1() => clearField(1);
  @$pb.TagNumber(1)
  HandRequest ensureHand1() => $_ensure(0);

  @$pb.TagNumber(2)
  HandRequest get hand2 => $_getN(1);
  @$pb.TagNumber(2)
  set hand2(HandRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHand2() => $_has(1);
  @$pb.TagNumber(2)
  void clearHand2() => clearField(2);
  @$pb.TagNumber(2)
  HandRequest ensureHand2() => $_ensure(1);
}

class CompareResponse extends $pb.GeneratedMessage {
  factory CompareResponse({
    $core.int? winner,
    HandResponse? hand1Result,
    HandResponse? hand2Result,
  }) {
    final $result = create();
    if (winner != null) {
      $result.winner = winner;
    }
    if (hand1Result != null) {
      $result.hand1Result = hand1Result;
    }
    if (hand2Result != null) {
      $result.hand2Result = hand2Result;
    }
    return $result;
  }
  CompareResponse._() : super();
  factory CompareResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CompareResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CompareResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'poker'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'winner', $pb.PbFieldType.O3)
    ..aOM<HandResponse>(2, _omitFieldNames ? '' : 'hand1Result', subBuilder: HandResponse.create)
    ..aOM<HandResponse>(3, _omitFieldNames ? '' : 'hand2Result', subBuilder: HandResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CompareResponse clone() => CompareResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CompareResponse copyWith(void Function(CompareResponse) updates) => super.copyWith((message) => updates(message as CompareResponse)) as CompareResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompareResponse create() => CompareResponse._();
  CompareResponse createEmptyInstance() => create();
  static $pb.PbList<CompareResponse> createRepeated() => $pb.PbList<CompareResponse>();
  @$core.pragma('dart2js:noInline')
  static CompareResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CompareResponse>(create);
  static CompareResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get winner => $_getIZ(0);
  @$pb.TagNumber(1)
  set winner($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWinner() => $_has(0);
  @$pb.TagNumber(1)
  void clearWinner() => clearField(1);

  @$pb.TagNumber(2)
  HandResponse get hand1Result => $_getN(1);
  @$pb.TagNumber(2)
  set hand1Result(HandResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHand1Result() => $_has(1);
  @$pb.TagNumber(2)
  void clearHand1Result() => clearField(2);
  @$pb.TagNumber(2)
  HandResponse ensureHand1Result() => $_ensure(1);

  @$pb.TagNumber(3)
  HandResponse get hand2Result => $_getN(2);
  @$pb.TagNumber(3)
  set hand2Result(HandResponse v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasHand2Result() => $_has(2);
  @$pb.TagNumber(3)
  void clearHand2Result() => clearField(3);
  @$pb.TagNumber(3)
  HandResponse ensureHand2Result() => $_ensure(2);
}

class SimRequest extends $pb.GeneratedMessage {
  factory SimRequest({
    $core.Iterable<$core.String>? holeCards,
    $core.Iterable<$core.String>? communityCards,
    $core.int? numSimulations,
  }) {
    final $result = create();
    if (holeCards != null) {
      $result.holeCards.addAll(holeCards);
    }
    if (communityCards != null) {
      $result.communityCards.addAll(communityCards);
    }
    if (numSimulations != null) {
      $result.numSimulations = numSimulations;
    }
    return $result;
  }
  SimRequest._() : super();
  factory SimRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SimRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SimRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'poker'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'holeCards')
    ..pPS(2, _omitFieldNames ? '' : 'communityCards')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'numSimulations', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SimRequest clone() => SimRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SimRequest copyWith(void Function(SimRequest) updates) => super.copyWith((message) => updates(message as SimRequest)) as SimRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimRequest create() => SimRequest._();
  SimRequest createEmptyInstance() => create();
  static $pb.PbList<SimRequest> createRepeated() => $pb.PbList<SimRequest>();
  @$core.pragma('dart2js:noInline')
  static SimRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimRequest>(create);
  static SimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get holeCards => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get communityCards => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get numSimulations => $_getIZ(2);
  @$pb.TagNumber(3)
  set numSimulations($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNumSimulations() => $_has(2);
  @$pb.TagNumber(3)
  void clearNumSimulations() => clearField(3);
}

class SimResponse extends $pb.GeneratedMessage {
  factory SimResponse({
    $core.double? winProbability,
    $core.double? tieProbability,
    $core.double? loseProbability,
    $core.int? simulationsRun,
  }) {
    final $result = create();
    if (winProbability != null) {
      $result.winProbability = winProbability;
    }
    if (tieProbability != null) {
      $result.tieProbability = tieProbability;
    }
    if (loseProbability != null) {
      $result.loseProbability = loseProbability;
    }
    if (simulationsRun != null) {
      $result.simulationsRun = simulationsRun;
    }
    return $result;
  }
  SimResponse._() : super();
  factory SimResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SimResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SimResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'poker'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'winProbability', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'tieProbability', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'loseProbability', $pb.PbFieldType.OD)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'simulationsRun', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SimResponse clone() => SimResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SimResponse copyWith(void Function(SimResponse) updates) => super.copyWith((message) => updates(message as SimResponse)) as SimResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimResponse create() => SimResponse._();
  SimResponse createEmptyInstance() => create();
  static $pb.PbList<SimResponse> createRepeated() => $pb.PbList<SimResponse>();
  @$core.pragma('dart2js:noInline')
  static SimResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimResponse>(create);
  static SimResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get winProbability => $_getN(0);
  @$pb.TagNumber(1)
  set winProbability($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWinProbability() => $_has(0);
  @$pb.TagNumber(1)
  void clearWinProbability() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get tieProbability => $_getN(1);
  @$pb.TagNumber(2)
  set tieProbability($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTieProbability() => $_has(1);
  @$pb.TagNumber(2)
  void clearTieProbability() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get loseProbability => $_getN(2);
  @$pb.TagNumber(3)
  set loseProbability($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLoseProbability() => $_has(2);
  @$pb.TagNumber(3)
  void clearLoseProbability() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get simulationsRun => $_getIZ(3);
  @$pb.TagNumber(4)
  set simulationsRun($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSimulationsRun() => $_has(3);
  @$pb.TagNumber(4)
  void clearSimulationsRun() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

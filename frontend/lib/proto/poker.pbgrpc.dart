///
//  Generated code. Do not modify.
//  source: poker.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'poker.pb.dart' as $0;
export 'poker.pb.dart';

class PokerServiceClient extends $grpc.Client {
  static final _$evaluateHand =
      $grpc.ClientMethod<$0.HandRequest, $0.HandResponse>(
          '/poker.PokerService/EvaluateHand',
          ($0.HandRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.HandResponse.fromBuffer(value));
  static final _$compareHands =
      $grpc.ClientMethod<$0.CompareRequest, $0.CompareResponse>(
          '/poker.PokerService/CompareHands',
          ($0.CompareRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.CompareResponse.fromBuffer(value));
  static final _$calculateProbability =
      $grpc.ClientMethod<$0.SimRequest, $0.SimResponse>(
          '/poker.PokerService/CalculateProbability',
          ($0.SimRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.SimResponse.fromBuffer(value));

  PokerServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.HandResponse> evaluateHand($0.HandRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$evaluateHand, request, options: options);
  }

  $grpc.ResponseFuture<$0.CompareResponse> compareHands(
      $0.CompareRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$compareHands, request, options: options);
  }

  $grpc.ResponseFuture<$0.SimResponse> calculateProbability(
      $0.SimRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$calculateProbability, request, options: options);
  }
}

abstract class PokerServiceBase extends $grpc.Service {
  $core.String get $name => 'poker.PokerService';

  PokerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HandRequest, $0.HandResponse>(
        'EvaluateHand',
        evaluateHand_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HandRequest.fromBuffer(value),
        ($0.HandResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CompareRequest, $0.CompareResponse>(
        'CompareHands',
        compareHands_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CompareRequest.fromBuffer(value),
        ($0.CompareResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SimRequest, $0.SimResponse>(
        'CalculateProbability',
        calculateProbability_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SimRequest.fromBuffer(value),
        ($0.SimResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.HandResponse> evaluateHand_Pre(
      $grpc.ServiceCall call, $async.Future<$0.HandRequest> request) async {
    return evaluateHand(call, await request);
  }

  $async.Future<$0.CompareResponse> compareHands_Pre(
      $grpc.ServiceCall call, $async.Future<$0.CompareRequest> request) async {
    return compareHands(call, await request);
  }

  $async.Future<$0.SimResponse> calculateProbability_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SimRequest> request) async {
    return calculateProbability(call, await request);
  }

  $async.Future<$0.HandResponse> evaluateHand(
      $grpc.ServiceCall call, $0.HandRequest request);
  $async.Future<$0.CompareResponse> compareHands(
      $grpc.ServiceCall call, $0.CompareRequest request);
  $async.Future<$0.SimResponse> calculateProbability(
      $grpc.ServiceCall call, $0.SimRequest request);
}

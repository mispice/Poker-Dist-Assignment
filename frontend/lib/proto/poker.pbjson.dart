///
//  Generated code. Do not modify.
//  source: poker.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use handRequestDescriptor instead')
const HandRequest$json = const {
  '1': 'HandRequest',
  '2': const [
    const {'1': 'hole_cards', '3': 1, '4': 3, '5': 9, '10': 'holeCards'},
    const {'1': 'community_cards', '3': 2, '4': 3, '5': 9, '10': 'communityCards'},
  ],
};

/// Descriptor for `HandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handRequestDescriptor = $convert.base64Decode('CgtIYW5kUmVxdWVzdBIdCgpob2xlX2NhcmRzGAEgAygJUglob2xlQ2FyZHMSJwoPY29tbXVuaXR5X2NhcmRzGAIgAygJUg5jb21tdW5pdHlDYXJkcw==');
@$core.Deprecated('Use handResponseDescriptor instead')
const HandResponse$json = const {
  '1': 'HandResponse',
  '2': const [
    const {'1': 'best_hand_name', '3': 1, '4': 1, '5': 9, '10': 'bestHandName'},
    const {'1': 'hand_rank_value', '3': 2, '4': 1, '5': 5, '10': 'handRankValue'},
    const {'1': 'best_cards', '3': 3, '4': 3, '5': 9, '10': 'bestCards'},
  ],
};

/// Descriptor for `HandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handResponseDescriptor = $convert.base64Decode('CgxIYW5kUmVzcG9uc2USJAoOYmVzdF9oYW5kX25hbWUYASABKAlSDGJlc3RIYW5kTmFtZRImCg9oYW5kX3JhbmtfdmFsdWUYAiABKAVSDWhhbmRSYW5rVmFsdWUSHQoKYmVzdF9jYXJkcxgDIAMoCVIJYmVzdENhcmRz');
@$core.Deprecated('Use compareRequestDescriptor instead')
const CompareRequest$json = const {
  '1': 'CompareRequest',
  '2': const [
    const {'1': 'hand1', '3': 1, '4': 1, '5': 11, '6': '.poker.HandRequest', '10': 'hand1'},
    const {'1': 'hand2', '3': 2, '4': 1, '5': 11, '6': '.poker.HandRequest', '10': 'hand2'},
  ],
};

/// Descriptor for `CompareRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compareRequestDescriptor = $convert.base64Decode('Cg5Db21wYXJlUmVxdWVzdBIoCgVoYW5kMRgBIAEoCzISLnBva2VyLkhhbmRSZXF1ZXN0UgVoYW5kMRIoCgVoYW5kMhgCIAEoCzISLnBva2VyLkhhbmRSZXF1ZXN0UgVoYW5kMg==');
@$core.Deprecated('Use compareResponseDescriptor instead')
const CompareResponse$json = const {
  '1': 'CompareResponse',
  '2': const [
    const {'1': 'winner', '3': 1, '4': 1, '5': 5, '10': 'winner'},
    const {'1': 'hand1_result', '3': 2, '4': 1, '5': 11, '6': '.poker.HandResponse', '10': 'hand1Result'},
    const {'1': 'hand2_result', '3': 3, '4': 1, '5': 11, '6': '.poker.HandResponse', '10': 'hand2Result'},
  ],
};

/// Descriptor for `CompareResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compareResponseDescriptor = $convert.base64Decode('Cg9Db21wYXJlUmVzcG9uc2USFgoGd2lubmVyGAEgASgFUgZ3aW5uZXISNgoMaGFuZDFfcmVzdWx0GAIgASgLMhMucG9rZXIuSGFuZFJlc3BvbnNlUgtoYW5kMVJlc3VsdBI2CgxoYW5kMl9yZXN1bHQYAyABKAsyEy5wb2tlci5IYW5kUmVzcG9uc2VSC2hhbmQyUmVzdWx0');
@$core.Deprecated('Use simRequestDescriptor instead')
const SimRequest$json = const {
  '1': 'SimRequest',
  '2': const [
    const {'1': 'hole_cards', '3': 1, '4': 3, '5': 9, '10': 'holeCards'},
    const {'1': 'community_cards', '3': 2, '4': 3, '5': 9, '10': 'communityCards'},
    const {'1': 'num_simulations', '3': 3, '4': 1, '5': 5, '10': 'numSimulations'},
  ],
};

/// Descriptor for `SimRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simRequestDescriptor = $convert.base64Decode('CgpTaW1SZXF1ZXN0Eh0KCmhvbGVfY2FyZHMYASADKAlSCWhvbGVDYXJkcxInCg9jb21tdW5pdHlfY2FyZHMYAiADKAlSDmNvbW11bml0eUNhcmRzEicKD251bV9zaW11bGF0aW9ucxgDIAEoBVIObnVtU2ltdWxhdGlvbnM=');
@$core.Deprecated('Use simResponseDescriptor instead')
const SimResponse$json = const {
  '1': 'SimResponse',
  '2': const [
    const {'1': 'win_probability', '3': 1, '4': 1, '5': 1, '10': 'winProbability'},
    const {'1': 'tie_probability', '3': 2, '4': 1, '5': 1, '10': 'tieProbability'},
    const {'1': 'lose_probability', '3': 3, '4': 1, '5': 1, '10': 'loseProbability'},
    const {'1': 'simulations_run', '3': 4, '4': 1, '5': 5, '10': 'simulationsRun'},
  ],
};

/// Descriptor for `SimResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simResponseDescriptor = $convert.base64Decode('CgtTaW1SZXNwb25zZRInCg93aW5fcHJvYmFiaWxpdHkYASABKAFSDndpblByb2JhYmlsaXR5EicKD3RpZV9wcm9iYWJpbGl0eRgCIAEoAVIOdGllUHJvYmFiaWxpdHkSKQoQbG9zZV9wcm9iYWJpbGl0eRgDIAEoAVIPbG9zZVByb2JhYmlsaXR5EicKD3NpbXVsYXRpb25zX3J1bhgEIAEoBVIOc2ltdWxhdGlvbnNSdW4=');

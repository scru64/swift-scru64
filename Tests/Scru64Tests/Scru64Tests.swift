import XCTest

@testable import Scru64

struct ExampleId: Sendable {
  let text: String
  let num: UInt64
  let timestamp: UInt64
  let nodeCtr: UInt32
}

struct ExampleNodeSpec: Sendable {
  let nodeSpec: String
  let canonical: String
  let specType: String
  let nodeId: UInt32
  let nodeIdSize: UInt8
  let nodePrev: UInt64
}

let exampleIds = [
  ExampleId(text: "000000000000", num: 0x0000_0000_0000_0000, timestamp: 0, nodeCtr: 0),
  ExampleId(text: "00000009zldr", num: 0x0000_0000_00ff_ffff, timestamp: 0, nodeCtr: 16_777_215),
  ExampleId(
    text: "zzzzzzzq0em8", num: 0x41c2_1cb8_e000_0000, timestamp: 282_429_536_480, nodeCtr: 0),
  ExampleId(
    text: "zzzzzzzzzzzz", num: 0x41c2_1cb8_e0ff_ffff, timestamp: 282_429_536_480,
    nodeCtr: 16_777_215),
  ExampleId(
    text: "0u375nxqh5cq", num: 0x0186_d52b_be2a_635a, timestamp: 6_557_084_606, nodeCtr: 2_777_946),
  ExampleId(
    text: "0u375nxqh5cr", num: 0x0186_d52b_be2a_635b, timestamp: 6_557_084_606, nodeCtr: 2_777_947),
  ExampleId(
    text: "0u375nxqh5cs", num: 0x0186_d52b_be2a_635c, timestamp: 6_557_084_606, nodeCtr: 2_777_948),
  ExampleId(
    text: "0u375nxqh5ct", num: 0x0186_d52b_be2a_635d, timestamp: 6_557_084_606, nodeCtr: 2_777_949),
  ExampleId(
    text: "0u375ny0glr0", num: 0x0186_d52b_bf2a_4a1c, timestamp: 6_557_084_607, nodeCtr: 2_771_484),
  ExampleId(
    text: "0u375ny0glr1", num: 0x0186_d52b_bf2a_4a1d, timestamp: 6_557_084_607, nodeCtr: 2_771_485),
  ExampleId(
    text: "0u375ny0glr2", num: 0x0186_d52b_bf2a_4a1e, timestamp: 6_557_084_607, nodeCtr: 2_771_486),
  ExampleId(
    text: "0u375ny0glr3", num: 0x0186_d52b_bf2a_4a1f, timestamp: 6_557_084_607, nodeCtr: 2_771_487),
  ExampleId(
    text: "jdsf1we3ui4f", num: 0x2367_c8df_b2e6_d23f, timestamp: 152_065_073_074,
    nodeCtr: 15_127_103),
  ExampleId(
    text: "j0afcjyfyi98", num: 0x22b8_6eaa_d6b2_f7ec, timestamp: 149_123_148_502,
    nodeCtr: 11_728_876),
  ExampleId(
    text: "ckzyfc271xsn", num: 0x16fc_2142_96b2_9057, timestamp: 98_719_318_678, nodeCtr: 11_702_359
  ),
  ExampleId(
    text: "t0vgc4c4b18n", num: 0x3504_295b_adc1_4f07, timestamp: 227_703_085_997,
    nodeCtr: 12_668_679),
  ExampleId(
    text: "mwcrtcubk7bp", num: 0x29d3_c755_3e74_8515, timestamp: 179_646_715_198, nodeCtr: 7_636_245
  ),
  ExampleId(
    text: "g9ye86pgplu7", num: 0x1dbb_2436_3718_aecf, timestamp: 127_693_764_151, nodeCtr: 1_617_615
  ),
  ExampleId(
    text: "qmez19t9oeir", num: 0x30a1_22fe_f7cd_6c83, timestamp: 208_861_855_479,
    nodeCtr: 13_462_659),
  ExampleId(
    text: "d81r595fq52m", num: 0x1827_8838_f066_0f2e, timestamp: 103_742_454_000, nodeCtr: 6_688_558
  ),
  ExampleId(
    text: "v0rbps7ay8ks", num: 0x38a9_e683_bb44_25ec, timestamp: 243_368_625_083, nodeCtr: 4_466_156
  ),
  ExampleId(
    text: "z0jndjt42op2", num: 0x3ff5_9674_8ea7_7186, timestamp: 274_703_217_806,
    nodeCtr: 10_973_574),
  ExampleId(
    text: "f2bembkd4zrb", num: 0x1b84_4eb5_d1ae_bb07, timestamp: 118_183_867_857,
    nodeCtr: 11_451_143),
  ExampleId(
    text: "mkg0fd5p76pp", num: 0x2939_1373_ab44_9abd, timestamp: 177_051_235_243, nodeCtr: 4_496_061
  ),
]

let exampleNodeSpecs = [
  ExampleNodeSpec(
    nodeSpec: "0/1", canonical: "0/1", specType: "dec_node_id", nodeId: 0, nodeIdSize: 1,
    nodePrev: 0x0000_0000_0000_0000),
  ExampleNodeSpec(
    nodeSpec: "1/1", canonical: "1/1", specType: "dec_node_id", nodeId: 1, nodeIdSize: 1,
    nodePrev: 0x0000_0000_0080_0000),
  ExampleNodeSpec(
    nodeSpec: "0/8", canonical: "0/8", specType: "dec_node_id", nodeId: 0, nodeIdSize: 8,
    nodePrev: 0x0000_0000_0000_0000),
  ExampleNodeSpec(
    nodeSpec: "42/8", canonical: "42/8", specType: "dec_node_id", nodeId: 42, nodeIdSize: 8,
    nodePrev: 0x0000_0000_002a_0000),
  ExampleNodeSpec(
    nodeSpec: "255/8", canonical: "255/8", specType: "dec_node_id", nodeId: 255, nodeIdSize: 8,
    nodePrev: 0x0000_0000_00ff_0000),
  ExampleNodeSpec(
    nodeSpec: "0/16", canonical: "0/16", specType: "dec_node_id", nodeId: 0, nodeIdSize: 16,
    nodePrev: 0x0000_0000_0000_0000),
  ExampleNodeSpec(
    nodeSpec: "334/16", canonical: "334/16", specType: "dec_node_id", nodeId: 334, nodeIdSize: 16,
    nodePrev: 0x0000_0000_0001_4e00),
  ExampleNodeSpec(
    nodeSpec: "65535/16", canonical: "65535/16", specType: "dec_node_id", nodeId: 65535,
    nodeIdSize: 16, nodePrev: 0x0000_0000_00ff_ff00),
  ExampleNodeSpec(
    nodeSpec: "0/23", canonical: "0/23", specType: "dec_node_id", nodeId: 0, nodeIdSize: 23,
    nodePrev: 0x0000_0000_0000_0000),
  ExampleNodeSpec(
    nodeSpec: "123456/23", canonical: "123456/23", specType: "dec_node_id", nodeId: 123456,
    nodeIdSize: 23, nodePrev: 0x0000_0000_0003_c480),
  ExampleNodeSpec(
    nodeSpec: "8388607/23", canonical: "8388607/23", specType: "dec_node_id", nodeId: 8_388_607,
    nodeIdSize: 23, nodePrev: 0x0000_0000_00ff_fffe),
  ExampleNodeSpec(
    nodeSpec: "0x0/1", canonical: "0/1", specType: "hex_node_id", nodeId: 0, nodeIdSize: 1,
    nodePrev: 0x0000_0000_0000_0000),
  ExampleNodeSpec(
    nodeSpec: "0x1/1", canonical: "1/1", specType: "hex_node_id", nodeId: 1, nodeIdSize: 1,
    nodePrev: 0x0000_0000_0080_0000),
  ExampleNodeSpec(
    nodeSpec: "0xb/8", canonical: "11/8", specType: "hex_node_id", nodeId: 11, nodeIdSize: 8,
    nodePrev: 0x0000_0000_000b_0000),
  ExampleNodeSpec(
    nodeSpec: "0x8f/8", canonical: "143/8", specType: "hex_node_id", nodeId: 143, nodeIdSize: 8,
    nodePrev: 0x0000_0000_008f_0000),
  ExampleNodeSpec(
    nodeSpec: "0xd7/8", canonical: "215/8", specType: "hex_node_id", nodeId: 215, nodeIdSize: 8,
    nodePrev: 0x0000_0000_00d7_0000),
  ExampleNodeSpec(
    nodeSpec: "0xbaf/16", canonical: "2991/16", specType: "hex_node_id", nodeId: 2991,
    nodeIdSize: 16, nodePrev: 0x0000_0000_000b_af00),
  ExampleNodeSpec(
    nodeSpec: "0x10fa/16", canonical: "4346/16", specType: "hex_node_id", nodeId: 4346,
    nodeIdSize: 16, nodePrev: 0x0000_0000_0010_fa00),
  ExampleNodeSpec(
    nodeSpec: "0xcc83/16", canonical: "52355/16", specType: "hex_node_id", nodeId: 52355,
    nodeIdSize: 16, nodePrev: 0x0000_0000_00cc_8300),
  ExampleNodeSpec(
    nodeSpec: "0xc8cd1/23", canonical: "822481/23", specType: "hex_node_id", nodeId: 822481,
    nodeIdSize: 23, nodePrev: 0x0000_0000_0019_19a2),
  ExampleNodeSpec(
    nodeSpec: "0x26eff5/23", canonical: "2551797/23", specType: "hex_node_id", nodeId: 2_551_797,
    nodeIdSize: 23, nodePrev: 0x0000_0000_004d_dfea),
  ExampleNodeSpec(
    nodeSpec: "0x7c6bc4/23", canonical: "8154052/23", specType: "hex_node_id", nodeId: 8_154_052,
    nodeIdSize: 23, nodePrev: 0x0000_0000_00f8_d788),
  ExampleNodeSpec(
    nodeSpec: "v0rbps7ay8ks/1", canonical: "v0rbps7ay8ks/1", specType: "node_prev", nodeId: 0,
    nodeIdSize: 1, nodePrev: 0x38a9_e683_bb44_25ec),
  ExampleNodeSpec(
    nodeSpec: "v0rbps7ay8ks/8", canonical: "v0rbps7ay8ks/8", specType: "node_prev", nodeId: 68,
    nodeIdSize: 8, nodePrev: 0x38a9_e683_bb44_25ec),
  ExampleNodeSpec(
    nodeSpec: "v0rbps7ay8ks/16", canonical: "v0rbps7ay8ks/16", specType: "node_prev", nodeId: 17445,
    nodeIdSize: 16, nodePrev: 0x38a9_e683_bb44_25ec),
  ExampleNodeSpec(
    nodeSpec: "v0rbps7ay8ks/23", canonical: "v0rbps7ay8ks/23", specType: "node_prev",
    nodeId: 2_233_078, nodeIdSize: 23, nodePrev: 0x38a9_e683_bb44_25ec),
  ExampleNodeSpec(
    nodeSpec: "z0jndjt42op2/1", canonical: "z0jndjt42op2/1", specType: "node_prev", nodeId: 1,
    nodeIdSize: 1, nodePrev: 0x3ff5_9674_8ea7_7186),
  ExampleNodeSpec(
    nodeSpec: "z0jndjt42op2/8", canonical: "z0jndjt42op2/8", specType: "node_prev", nodeId: 167,
    nodeIdSize: 8, nodePrev: 0x3ff5_9674_8ea7_7186),
  ExampleNodeSpec(
    nodeSpec: "z0jndjt42op2/16", canonical: "z0jndjt42op2/16", specType: "node_prev", nodeId: 42865,
    nodeIdSize: 16, nodePrev: 0x3ff5_9674_8ea7_7186),
  ExampleNodeSpec(
    nodeSpec: "z0jndjt42op2/23", canonical: "z0jndjt42op2/23", specType: "node_prev",
    nodeId: 5_486_787, nodeIdSize: 23, nodePrev: 0x3ff5_9674_8ea7_7186),
  ExampleNodeSpec(
    nodeSpec: "f2bembkd4zrb/1", canonical: "f2bembkd4zrb/1", specType: "node_prev", nodeId: 1,
    nodeIdSize: 1, nodePrev: 0x1b84_4eb5_d1ae_bb07),
  ExampleNodeSpec(
    nodeSpec: "f2bembkd4zrb/8", canonical: "f2bembkd4zrb/8", specType: "node_prev", nodeId: 174,
    nodeIdSize: 8, nodePrev: 0x1b84_4eb5_d1ae_bb07),
  ExampleNodeSpec(
    nodeSpec: "f2bembkd4zrb/16", canonical: "f2bembkd4zrb/16", specType: "node_prev", nodeId: 44731,
    nodeIdSize: 16, nodePrev: 0x1b84_4eb5_d1ae_bb07),
  ExampleNodeSpec(
    nodeSpec: "f2bembkd4zrb/23", canonical: "f2bembkd4zrb/23", specType: "node_prev",
    nodeId: 5_725_571, nodeIdSize: 23, nodePrev: 0x1b84_4eb5_d1ae_bb07),
  ExampleNodeSpec(
    nodeSpec: "mkg0fd5p76pp/1", canonical: "mkg0fd5p76pp/1", specType: "node_prev", nodeId: 0,
    nodeIdSize: 1, nodePrev: 0x2939_1373_ab44_9abd),
  ExampleNodeSpec(
    nodeSpec: "mkg0fd5p76pp/8", canonical: "mkg0fd5p76pp/8", specType: "node_prev", nodeId: 68,
    nodeIdSize: 8, nodePrev: 0x2939_1373_ab44_9abd),
  ExampleNodeSpec(
    nodeSpec: "mkg0fd5p76pp/16", canonical: "mkg0fd5p76pp/16", specType: "node_prev", nodeId: 17562,
    nodeIdSize: 16, nodePrev: 0x2939_1373_ab44_9abd),
  ExampleNodeSpec(
    nodeSpec: "mkg0fd5p76pp/23", canonical: "mkg0fd5p76pp/23", specType: "node_prev",
    nodeId: 2_248_030, nodeIdSize: 23, nodePrev: 0x2939_1373_ab44_9abd),
]

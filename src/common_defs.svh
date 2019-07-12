`ifndef COMMON_DEFS_SVH
`define COMMON_DEFS_SVH

/*
	This header defines data structures and constants used in the whole SOPC
*/

// project configuration
`default_nettype wire
`timescale 1ns / 1ps

`include "compile_options.svh"

typedef logic [7:0]   uint8_t;
typedef logic [15:0]  uint16_t;
typedef logic [31:0]  uint32_t;
typedef logic [63:0]  uint64_t;
typedef uint32_t      virt_t;
typedef uint32_t      phys_t;

// interface of I$ and CPU
// I$ is 2-stage pipelined
interface cpu_ibus_if();
	logic read;
	logic stall, valid;
	phys_t address;   // aligned in 8-bytes
	uint64_t rddata;

	// indicate that corresponding stage shall be directly terminated.
	// flush_1 will be '1' whenever flush_2 is '1'.
	// stall shall be '0' whenever flush_2 is '1'.
	logic flush_1, flush_2;

    modport master (
		output read, address,
		output flush_1, flush_2,
		input  stall, rddata, valid
    );

    modport slave (
		input  read, address,
		input  flush_1, flush_2,
		output stall, rddata, valid
    );

endinterface

// interface of D$ and CPU
interface cpu_dbus_if();
	// invalidate I$ and D$ respectively
	logic icache_inv, dcache_inv;
	// signals for D$
	logic read, write, stall;
	// signals for uncached memory access 
	logic uncached_read, uncached_write, uncached_stall;
	// only used for write
	// byteenable[i] corresponds to wrdata[(i + 1) * 8 - 1 : i * 8]
	logic [3:0] byteenable;
	phys_t address;      // aligned in 4-bytes
	uint32_t rddata, wrdata, uncached_rddata;

    modport master (
		output read, write,
		output uncached_read, uncached_write,
		output wrdata, address, byteenable,
		output icache_inv, dcache_inv,
		input  stall, uncached_stall,
		input  rddata, uncached_rddata
    );

    modport slave (
		input  read, write,
		input  uncached_read, uncached_write,
		input  wrdata, address, byteenable,
		input  icache_inv, dcache_inv,
		output stall, uncached_stall,
		output rddata, uncached_rddata
    );

endinterface

`endif

// Asynchronous FIFO Implementation

`include "fifomem.v"      // FIFO memory module
`include "sync_r2w.v"     // Synchronizer for read pointer to write clock domain
`include "sync_w2r.v"     // Synchronizer for write pointer to read clock domain
`include "rptr_empty.v"   // Read pointer and empty flag logic
`include "wptr_full.v"    // Write pointer and full flag logic

// Top-level wrapper module for Asynchronous FIFO
module async_fifo 
  #(parameter DSIZE = 8,   // Data bus width
   parameter ASIZE = 4)    // Address bus width
  
  (input winc, wclk, wrst_n,    // Write enable signal, write clock, write reset (active low)
   input rinc, rclk, rrst_n,    // Read enable signal, read clock, read reset (active low)
   input [DSIZE-1:0] wdata,     // Data to be written to FIFO
   output [DSIZE-1:0] rdata,    // Data read from FIFO
   output wfull,                // Flag indicating FIFO is full
   output rempty                // Flag indicating FIFO is empty
  );
  
  wire [ASIZE-1:0] waddr, raddr;           // Write and read addresses within the FIFO memory
  wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr; // Gray-coded write and read pointers, synchronized across clock domains
  
  // Synchronize read pointer to write clock domain
  sync_r2w #(.ADDRSIZE(ASIZE)) sync_r2w (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rptr(rptr),
    .wq2_rptr(wq2_rptr)
  );
  
  // Synchronize write pointer to read clock domain
  sync_w2r #(.ADDRSIZE(ASIZE)) sync_w2r (
    .rq2_wptr(rq2_wptr),
    .wptr(wptr),
    .rclk(rclk),
    .rrst_n(rrst_n)
  );

  // Instantiate FIFO memory module for storing data
  fifomem #(.DATASIZE(DSIZE), .ADDRSIZE(ASIZE)) fifomem (
    .rdata(rdata),
    .wdata(wdata),
    .waddr(waddr),
    .raddr(raddr),
    .winc(winc), 
    .wclk(wclk),
    .wfull(wfull)
  );
  
  // Instantiate for detecting empty condition in read pointer
  rptr_empty #(.ADDRSIZE(ASIZE)) rptr_empty (
    .rempty(rempty),
    .raddr(raddr),
    .rptr(rptr),
    .rq2_wptr(rq2_wptr),
    .rinc(rinc),
    .rclk(rclk),
    .rrst_n(rrst_n)
  );

  // Instantiate for detecting full condition in write pointer
  wptr_full #(.ADDRSIZE(ASIZE)) wptr_full (
    .wfull(wfull),
    .waddr(waddr),
    .wptr(wptr),
    .wq2_rptr(wq2_rptr),
    .winc(winc),
    .wclk(wclk),
    .wrst_n(wrst_n)
  );
  
endmodule

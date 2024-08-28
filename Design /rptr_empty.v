// Read Pointer Logic for Empty Detection

module rptr_empty
  #(parameter ADDRSIZE = 4) // Parameter to define the size of the address in bits
  
  (input rclk,                // Read clock input signal
   input rrst_n,              // Active-low read reset signal
   input rinc,                // Read increment signal
   input [ADDRSIZE:0] rq2_wptr,// Synchronized write pointer from write clock domain
   
   output reg rempty,         // Output flag indicating if FIFO is empty
   output [ADDRSIZE-1:0] raddr,// Memory read address output
   output reg [ADDRSIZE:0] rptr);// Current read pointer value
  
  reg [ADDRSIZE:0] rbin;      // Binary version of the read pointer

  // Next state of the read pointer in Gray and binary formats
  wire [ADDRSIZE:0] rgraynext, rbinnext; 
  
  wire rempty_val;            // Internal signal for empty detection
  
  // Always block to update the read pointer and its binary version on the rising edge of the read clock
  always @(posedge rclk or negedge rrst_n)
    if(!rrst_n)               // On reset
      {rbin, rptr} <= 0;      // Initialize read pointer and binary version to zero
    else
      {rbin, rptr} <= {rbinnext, rgraynext}; // Update with next states
  
  // Memory read address determined by the lower bits of the binary read pointer
  assign raddr = rbin[ADDRSIZE-1:0]; 

  // Calculate the next binary read pointer based on read increment signal and empty status
  assign rbinnext = rbin + (rinc & ~rempty);
  
  // Convert the next binary value to a Gray code format
  assign rgraynext = (rbinnext >> 1) ^ rbinnext;

  // FIFO is empty when the next Gray pointer is equal to the synchronized write pointer or on reset
  assign rempty_val = (rgraynext == rq2_wptr);
  
  // Always block to update the empty status on the rising edge of the read clock
  always @(posedge rclk or negedge rrst_n)
    if(!rrst_n)
      rempty <= 1'b1;        // Set rempty to true on reset
    else
      rempty <= rempty_val;  // Update rempty based on calculated empty status
  
endmodule
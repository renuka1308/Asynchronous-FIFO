// Write Pointer for Full Detection

module wptr_full
  #(parameter ADDRSIZE = 4) // Parameter to define address size
  
  (
   input winc,                // Write increment signal
   input wclk,                // Write clock signal
   input wrst_n,              // Active-low write reset signal
   input [ADDRSIZE:0] wq2_rptr,// Synchronized read pointer input
   output reg wfull,          // Output flag indicating if FIFO is full
   output [ADDRSIZE-1:0] waddr,// Memory write address output
   output reg [ADDRSIZE:0] wptr // Current write pointer
  );

  reg [ADDRSIZE:0] wbin;      // Binary representation of the write pointer
  wire [ADDRSIZE:0] wbinnext, wgraynext; // Next binary and Gray code pointers
  
  wire wfull_value;           // Internal signal for full condition detection

  // Update the binary and write pointers on clock edge or reset
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n)
      {wbin, wptr} <= 0;      // Reset pointers to zero
    else
      {wbin, wptr} <= {wbinnext, wgraynext}; // Update pointers

  // Assign memory write address from binary pointer
  assign waddr = wbin[ADDRSIZE-1:0]; 
  
  // Calculate the next binary pointer
  assign wbinnext = wbin + (winc & ~wfull);
  
  // Convert the next binary pointer to Gray code
  assign wgraynext = (wbinnext >> 1) ^ wbinnext;

  // Determine if FIFO is full based on the read pointer comparison
  assign wfull_value = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]}); 

  // Update the full status on clock edge or reset
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n)
      wfull <= 0;            // Set wfull to false on reset
    else
      wfull <= wfull_value;  // Update wfull based on the condition

endmodule
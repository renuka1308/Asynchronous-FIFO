// Read Pointer to Write Clock Synchronizer

module sync_r2w 
  #(parameter ADDRSIZE = 4) // Size of the address in bits, determining the width of the pointers.
  
  (input wclk,                // Write clock input signal
   input wrst_n,              // Active-low write reset signal
   input [ADDRSIZE:0] rptr,   // Read pointer input
   output reg [ADDRSIZE:0] wq2_rptr); // Synchronized read pointer output to the write clock domain
  
  reg [ADDRSIZE:0] wq1_rptr;  // Temporary storage element to hold intermediate read pointer values
  
  // Always block triggers on rising edge of wclk or falling edge of wrst_n
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n)               // If reset is active (low)
      {wq1_rptr, wq2_rptr} <= 0; // Set both wq1_rptr and wq2_rptr to zero
    
    else                        // Otherwise, update synchronized pointers
      {wq2_rptr, wq1_rptr} <= {wq1_rptr, rptr}; // Pass current rptr and store former value in wq1_rptr
  
endmodule
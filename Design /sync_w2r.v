// Write Pointer to Read Clock Synchronizer

module sync_w2r 
  #(parameter ADDRSIZE = 4) // Size of the address in bits, determining the width of the pointers.
  
  (input rclk,                // Read clock input signal
   input rrst_n,              // Active-low read reset signal
   input [ADDRSIZE:0] wptr,   // Write pointer input
   output reg [ADDRSIZE:0] rq2_wptr); // Synchronized write pointer output to the read clock domain
  
  reg [ADDRSIZE:0] rq1_wptr;  // Temporary storage for intermediate write pointer values
  
  // Always block triggers on the rising edge of rclk or falling edge of rrst_n
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n)               // If reset is active (low)
      {rq1_wptr, rq2_wptr} <= 0; // Reset both rq1_wptr and rq2_wptr to zero
    
    else                        // If not resetting, synchronize the write pointer
      {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr}; // Update the synchronized pointers
  
endmodule

// FIFO Memory Implementation

module fifomem
  #(parameter DATASIZE = 8,  // Memory data word width (e.g., 8 bits)
    parameter ADDRSIZE = 4)   // Number of memory address bits (e.g., 2^4 = 16 locations)
  
  (input wclk,                // Write clock signal
   input winc,                // Write enable signal
   input wfull,               // Flag indicating if the FIFO is full
   input [ADDRSIZE-1:0] waddr,// Write address input
   input [ADDRSIZE-1:0] raddr,// Read address input
   input [DATASIZE-1:0] wdata,// Data to be written into FIFO
   output [DATASIZE-1:0] rdata// Data read from FIFO
  );
  
  localparam DEPTH = 1 << ADDRSIZE;  // Calculate memory depth: 2^ADDRSIZE (e.g., 2^4 = 16 locations)

  reg [DATASIZE-1:0] mem [0 : DEPTH-1]; // Declare memory array of size DEPTH

  assign rdata = mem[raddr]; // Read data from the memory at the specified read address

  always @(posedge wclk)      // Trigger on the rising edge of the write clock
    if (winc && !wfull)      // Check if write enable is active and FIFO is not full
      mem[waddr] = wdata;    // Write data into the memory at the specified write address
      
endmodule
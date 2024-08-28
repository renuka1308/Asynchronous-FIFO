// Asynchronous FIFO Testbench

module async_fifo_tb;

  parameter DSIZE = 8;  // Data width (number of bits per data word)
  parameter ASIZE = 4;  // Address width (number of bits for addressing)

  // Signals
  reg [DSIZE-1:0] wdata; // Data to be written
  reg winc, wclk, wrst_n; // Write increment signal, write clock, active-low reset
  reg rinc, rclk, rrst_n; // Read increment signal, read clock, active-low reset
  wire [DSIZE-1:0] rdata; // Data read from FIFO
  wire wfull, rempty;     // Flags indicating full and empty states

  // FIFO depth storage: circular buffer to hold data
  reg [DSIZE-1:0] wdata_q [0:(1 << ASIZE)-1]; 
  integer write_ptr, read_ptr; // Pointers to track read and write positions

  // Instantiate the FIFO module
  async_fifo #(.DSIZE(DSIZE), .ASIZE(ASIZE)) dut (
    .winc(winc),
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rinc(rinc),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .wdata(wdata),
    .rdata(rdata),
    .wfull(wfull),
    .rempty(rempty)
  );

  // Clock generation for write operations
  initial begin
    wclk = 1'b0; // Initialize write clock
    forever #10 wclk = ~wclk;  // Toggle every 10 time units (100 MHz clock)
  end

  // Clock generation for read operations
  initial begin
    rclk = 1'b0; // Initialize read clock
  forever #20 rclk = ~rclk;  // Toggle every 20 time units (50 MHz clock)
  end

  // Write operations
  initial begin
    wdata = 8'h00; // Initial write data
    winc = 1'b0;   // Write increment signal (initially off)
    wrst_n = 1'b0; // Assert write reset
    write_ptr = 0; // Initialize write pointer
    #20;  // Wait for clocks to stabilize
    wrst_n = 1'b1;  // Deassert write reset

    // Repeat for two write cycles
    repeat(2) begin
      for (integer i = 0; i < 30; i = i + 1) begin
        @(posedge wclk);
        if (!wfull) begin // Only proceed if FIFO is not full
          winc = (i % 2 == 0) ? 1'b1 : 1'b0; // Alternate winc signal
          if (winc) begin
            wdata = $random; // Generate random data
            wdata_q[write_ptr] = wdata; // Store written data in array
            write_ptr = (write_ptr + 1) % (1 << ASIZE); // Circular increment
          end
        end
      end
      #50; // Wait between write batches
    end
  end

  // Read operations
  initial begin
    rinc = 1'b0; // Read increment signal (initially off)
    rrst_n = 1'b0; // Assert read reset
    read_ptr = 0; // Initialize read pointer
    #20;  // Wait for clocks to stabilize
    rrst_n = 1'b1;  // Deassert read reset

    // Repeat for two read cycles
    repeat(2) begin
      for (integer i = 0; i < 30; i = i + 1) begin
        @(posedge rclk);
        if (!rempty) begin // Only proceed if FIFO is not empty
          rinc = (i % 2 == 0) ? 1'b1 : 1'b0; // Alternate rinc signal
          if (rinc) begin
            // Check if read data matches expected value
            if (rdata !== wdata_q[read_ptr]) 
              $error("Time = %0t: Comparison Failed: expected wdata = %h, rdata = %h", $time, wdata_q[read_ptr], rdata);
            else 
              $display("Time = %0t: Comparison Passed: wdata = %h and rdata = %h", $time, wdata_q[read_ptr], rdata);
            read_ptr = (read_ptr + 1) % (1 << ASIZE); // Circular increment
          end
        end
      end
      #50; // Wait between read batches
    end
    $finish; // End simulation
  end

  // Dump waveforms for debugging
  initial begin 
    $dumpfile("async_fifo.vcd"); 
    $dumpvars(0, async_fifo_tb); // Dump all variables in this module
    
    // Monitor relevant signals
    $monitor("Time = %0t: wdata = %h, rdata = %h, wdata_q[write_ptr] = %h, wfull = %b, rempty = %b",
             $time, wdata, rdata, wdata_q[write_ptr], wfull, rempty);
  end

endmodule
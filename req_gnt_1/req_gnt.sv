// systemverilog assertion
// check that upon req, gnt comes no earlier than 3 and no longer than 10
// cycles
//

module req_gnt;

bit req, gnt, clk, rst;

initial begin
  clk = 0;
  forever
    clk = #10 ~clk;
end

initial begin
  rst = 1;
  #50ns;
  rst = 0;
end

initial begin
  wait (rst == 0);
  #100ns;
  @(posedge clk); // 150ns
  req = 1;
  @(posedge clk); // 170ns
  req = 0;
  repeat (12) @(posedge clk); // 410ns
  req = 0;
  @(posedge clk); // 430ns
  req = 0;
end

initial begin
  wait (req == 1); // 150ns
  @(posedge clk); // sva sees req at 170ns - clk 0
  repeat(1) @(posedge clk); // 190ns clk 1
  gnt = 0;
  @(posedge clk); // 210ns clk 2
  gnt = 0; 

  @(posedge clk); // 230ns, clk 3
  gnt = 1;
  @(posedge clk); // sva sees gnt at clk 4, 250ns
  gnt = 0; 
  #200ns;
  $finish();
end

property p_req_gnt;
  @(posedge clk)
  disable iff (rst)

  req |-> !gnt[*3] ##1 ( (gnt[=1]) intersect (1[*8]) ) #=# always !gnt;

endproperty

a_req_gnt: assert property(p_req_gnt);

endmodule

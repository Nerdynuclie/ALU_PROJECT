
`timescale 1ns/1ps

module alu_testbench;
    parameter N=4;    
    reg [N-1:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0] INP_VALID;
    reg [C-1:0] CMD;
    
    
    wire [2*N:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    wire [2*N:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;
    integer i; //for loop
   
    ALU_design #(.N(N)) dut (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .CLK(CLK), .RST(RST), .CMD(CMD),
        .CE(CE), .MODE(MODE),.INP_VALID(INP_VALID),w
        .RES(RES_dut),
        .G(G_dut), .E(E_dut), .L(L_dut),
        .ERR(ERR_dut)
    );

  
    ALU_reference_model #(.N(N)) ref (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .MODE(MODE), .CMD(CMD),.INP_VALID(INP_VALID),
        .EXP_RES(RES_ref),
        .EXP_COUT(COUT_ref), .EXP_OFLOW(OFLOW_ref),
        .G(G_ref), .E(E_ref), .L(L_ref),
        .EXP_ERR(ERR_ref)
    );

   
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    
    initial begin
      
        RST = 1; CE = 1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0;
        
        @(posedge CLK);
        RST = 0;  
        @(posedge CLK);

        
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== Testing ERROR cases (MODE=1 and 0) ===");
        test_ERROR_cases();

        
        $display("\n=== Testing Corner cases(MODE=0 and 1) ===");
        test_corner_cases();
        
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

    
    task test_arithmetic();
        begin
    apply_test(4'd1,4'd2,4'd0,2'd3,1'b0,"ADD",2);//add
    apply_test(4'd4,4'd2,4'd1,2'd3,1'b0,"SUB",2);//subtraction
    apply_test(4'd4,4'd2,4'd2,2'd3,1'b1,"ADD_CIN",2);//ADD_CIN
    apply_test(4'd4,4'd2,4'd3,2'd3,1'b1,"SUB_CIN",2);//SUB_CIN
    apply_test(4'd4,4'd2,4'd4,2'd1,1'b0,"INC_A",2);//INC_A
    apply_test(4'd4,4'd2,4'd5,2'd1,1'b0,"DEC_A",2);//DEC_A
    apply_test(4'd4,4'd2,4'd6,2'd2,1'b0,"INC_B",2);//INC_B
    apply_test(4'd4,4'd2,4'd7,2'd2,1'b1,"DEC_B",2);//DEC_B
    apply_test(4'd4,4'd2,4'd8,2'd3,1'b1,"CMP_G",2);//CMP for OPA greater than OPB
    apply_test(4'd4,4'd4,4'd8,2'd3,1'b1,"CMP_E",2);//CMP for OPA equal to OPB
    apply_test(4'd2,4'd4,4'd8,2'd3,1'b1,"CMP_L",2);//CMP for OPA less than OPB
    apply_test(4'd4,4'd2,4'd9,2'd3,1'b1,"INC_and_MUL",3);//Increment OPA and OPB and multiply
    apply_test(4'd4,4'd2,4'd10,2'd3,1'b1,"SHIFT_and_MUL",3);//keft SHIIFT OPA and multiply with OPB
    apply_test(4'd4,4'd2,4'd11,2'd2,1'b1,"Signed_ADD",2);//Signed_ADD
    apply_test(4'd4,15'd2,9'd12,2'd2,1'b1,"SIgned_SUB",2);//signed_SUB
    
        end
    endtask

    
    task test_logical();
        begin
        
            apply_test(4'd1,4'd1,4'd0,2'd3,1'b0,"AND",2);//AND
  apply_test(4'd5,4'd10,4'd1,2'd3,1'b0,"NAND",2);//NAND
  apply_test(4'd1,4'd15,4'd2,2'd3,1'b0,"OR",2);//OR
  apply_test(4'd1,4'd15,4'd3,2'd3,1'b0,"NOR",2);//NOR
  apply_test(4'd10,4'd5,4'd4,2'd3,1'b0,"XOR",2);//XOR
  apply_test(4'd15,4'd15,4'd5,2'd3,1'b0,"XNOR",2);//XNOR
  apply_test(4'd1,4'd15,4'd6,2'd1,1'b0,"NOT_A",2);//NOT OPA
  apply_test(4'd15,4'd1,4'd7,2'd2,1'b0,"AND",2);//NOT OPB
  apply_test(4'd1,4'd15,4'd8,2'd1,1'b0,"SHR1_A",2);//SHIFT right OPA
  apply_test(4'd8,4'd0,4'd9,2'd1,1'b0,"SHL1_A",2);//SHIFT left OPA
  apply_test(4'd1,4'd8,4'd10,2'd2,1'b0,"AND",2);//SHIFT right OPB
  apply_test(4'd1,4'd1,4'd11,2'd2,1'b0,"SHL1_B",2);//Shift left OPB
  apply_test(4'd8,4'd2,4'd12,2'd3,1'b0,"ROl_A_B",2);//Rotate OPA left OPB times
  apply_test(4'd1,4'd2,4'd13,2'd3,1'b0,"ROR_A_B",2);//rotate OPA right OPB times
           
        end
    endtask

   task test_ERROR_cases();
   begin
    //ERROR CASES (INP_VALID AND FOR Rotation) 
    //for MODE=1 (arithemetic)
    MODE=1;
  apply_test(4'd10,4'd15,4'd9,2'd0,1'b1,"INP_VALID=00",2);//INP_VALID=00
    for(i=0;i<=12;i=i+1) begin
      apply_test(4'd10,4'd15,i,2'd1,1'b1,"INP_VALID=01",2);//INP_VALID=01
    end
    for(i=0;i<=12;i=i+1) begin
      apply_test(4'd10,4'd15,i,2'd2,1'b1,"INP_VALID=10",2);//INP_VALID=10
    end

    //for MODE=0 (Logical)
    MODE=0;
  apply_test(4'd10,4'd15,4'd9,2'd0,1'b1,"INP_VALID=00",2);//INP_VALID=00
    for(i=0;i<=12;i=i+1) begin
      apply_test(4'd10,4'd15,i,2'd1,1'b1,"INP_VALID=01",2);//INP_VALID=01
    end
    for(i=0;i<=12;i=i+1) begin
      apply_test(4'd10,4'd15,i,2'd2,1'b1,"INP_VALID=10",2);//INP_VALID=10
    end
   end
   endtask

   task test_corner_cases();
   begin
      //CORNER CASES
    MODE=1;
    for(i=0;i<=12;i=i+1)  begin
        apply_test(4'd0,4'd0,i,2'd3,1'd1,"ALL zeros(MODE=1)",2);
    end    
    for(i=0;i<=12;i=i+1) begin
        apply_test(4'd15,4'd15,i,2'd3,1'd1,"ALL_ones(MODE=1)",2);
    end
    
    MODE=0;
        for(i=0;i<=13;i=i+1)  begin
        apply_test(4'd0,4'd0,i,2'd3,1'd1,"ALL_zeros(MODE=0)",2);
    end    
    for(i=0;i<=13;i=i+1) begin
        apply_test(4'd15,4'd15,i,2'd3,1'd1,"ALL_ONES(MODE=0",2);
    end
   end
   endtask

   task apply_test 
(
    input [N-1:0] a, b,
    input [3:0] cmd,
    input [1:0] inp_valid,
    input CIN,
    input [80*8:1] test_name,
    input integer wait_cycles
);
integer i;

begin


    @(negedge CLK);

    OPA = a;
    OPB = b;
    CMD = cmd;
    INP_VALID = inp_valid;


    for(i=0; i<=wait_cycles; i=i+1)
        @(posedge CLK);


    test_count = test_count + 1;

    if(compare_outputs(1'b0)) begin
        $display("[PASS] %s", test_name);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] %s", test_name);
        display_mismatch();
        fail_count = fail_count + 1;
    end

end
endtask

    
  function [0:0] compare_outputs;
input dummy;

begin
    compare_outputs =
        (RES_dut    === RES_ref)   &&
        (COUT_dut  === COUT_ref)  &&
        (OFLOW_dut === OFLOW_ref) &&
        (G_dut     === G_ref)     &&
        (E_dut     === E_ref)     &&
        (L_dut     === L_ref)     &&
        (ERR_dut   === ERR_ref);
end
endfunction

    
   

   
    task display_mismatch();
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
            $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end

endmodule

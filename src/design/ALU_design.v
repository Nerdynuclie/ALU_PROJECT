module ALU_design#(parameter N=4)(OPA,OPB,CIN,CLK,RST,INP_VALID,CMD,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);


//Input output port declaration
  input [N-1:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN;
  input [1:0] INP_VALID;
  input [3:0] CMD;
  output reg [(2*N)-1:0] RES=0;
  output reg COUT =0;
  output reg OFLOW=0;
  output reg G=0;
  output reg E=0;
  output reg L =0;
  output reg ERR=0;

//Temporary register declaration
  reg [N:0] sum;//for signed addition operations
  reg [N:0] diff;//for signed subtraction
//Multiplication  control
reg[1:0] mul_count;
reg [2*N-1:0] temp_mul;
reg mul_active;
reg [3:0] mul_cmd;
wire is_mul_cmd;
assign is_mul_cmd=(CMD==4'b1001 || CMD==4'b1010);
always@(posedge CLK)
      begin
         if(RST)                // If reset is active high all output signals are equal to zero
          begin
            RES<=0;
            COUT<=0;
            OFLOW<=0;
            G<=0;
            E<=0;
            L<=0;
            ERR<=0;
          end
       
       else if(CE)                   // If clock enable is active high then check for other control signals
        begin
          if(mul_active)  //for multiplication making the result to appear at 3rd clk cycle
         begin
            if(INP_VALID!=2'b11) begin
                RES<=0;
                ERR<=1;
                mul_active<=0;
                mul_count<=0;
            end
            else if(CMD!=mul_cmd) begin
                mul_active<=0;
                mul_count<=0;
                RES<=RES;
            end
            else
            mul_count<=mul_count+1;
            if(mul_count==0) begin
              RES<=2*N-1'bx;
            end
            else if(mul_count==1) begin
                RES<=temp_mul;
                mul_active<=0;
                mul_count<=0;
            end
         end
         else if(MODE)
         begin
           RES<=0;
           COUT<=1'b0;
           OFLOW<=1'b0;
           G<=1'b0;
           E<=1'b0;
           L<=1'b0;
           ERR<=1'b0;
          case(CMD)             // CMD is the binary code value of the Arithmetic Operation
           4'b0000:             // CMD = 0000: ADD 
            begin  
                if(INP_VALID==2'b11) begin      
                    RES<=OPA+OPB;
                    
                    COUT<=({1'b0,OPA}+{1'b0,OPB})>>N;
            end
            else begin
                RES<=0;
                ERR<=1;
            end
            end
	   4'b0001:             // CMD = 0001: SUB
            begin
                if(INP_VALID==2'b11) begin
                    OFLOW<=(OPA<OPB)?1:0;
                    RES<=OPA-OPB;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
            end
           4'b0010:             // CMD = 0010: ADD_CIN
            begin
                if(INP_VALID==2'b11) begin
                    RES<=OPA+OPB+CIN;
                    COUT<=({1'b0,OPA}+{1'b0,OPB}+CIN)>>N;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
            end
           4'b0011:            // CMD = 0011: SUB_CIN. Here we set the overflow flag
           begin
             if(INP_VALID==2'b11) begin
                OFLOW<=(OPA<OPB)?1:0;
                RES<=OPA-OPB-CIN;    
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end
           4'b0100:begin  // CMD = 0100: INC_A
            if(INP_VALID==2'b11 || INP_VALID==2'b01) begin 
                RES<=OPA+1;  
                COUT<=({1'b0,OPA}+1'b1)>>N; 
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end

           4'b0101: begin  // CMD = 0101: DEC_A
            if(INP_VALID==2'b11 || INP_VALID==2'b01) begin 
                RES<=OPA-1;
                OFLOW<=(OPA<1'b1)? 1'b1: 1'b0;   
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end
           4'b0110:begin // CMD = 0110: INC_B
            if(INP_VALID==2'b11 || INP_VALID==2'b10) begin 
                RES<=OPB+1;
                COUT<=({1'b0,OPB}+1'b1)>>N;   
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end
           4'b0111: begin  // CMD = 0111: DEC_B
            if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
                RES<=OPB-1'b1;
                OFLOW<=(OPB<1'b1)? 1: 0;
                ERR<=0;
            end
            else begin
                RES<=1;
                ERR<=1;
            end
           end   
           4'b1000:              // CMD = 1000: CMP
           begin
            RES<=0;
            if(INP_VALID==2'b11) begin
            if(OPA==OPB)
             begin
               E<=1'b1;
               G<=1'b0;
               L<=1'b0;
             end

            else if(OPA>OPB)
             begin
               E<=1'b0;
               G<=1'b1;
               L<=1'b0;
             end
            else 
             begin
               E<=1'b0;
               G<=1'b0;
               L<=1'b1;
             end
           end
           else begin
            E<=0;
            G<=0;
            L<=0;
            ERR<=0;
           end
           end
           4'b1001: begin
            if(INP_VALID==2'b11) begin
                temp_mul<=(OPA+1)*(OPB+1);
                mul_count<=0;
                mul_active<=1;
                mul_cmd<=CMD;
            end
            else begin
                ERR<=1;
                RES<=0;
            end
           end
           4'b1010: begin
            if(INP_VALID==2'b11) begin
                temp_mul<=(OPA<<1)*OPB;
                mul_count<=0;
                mul_active<=1;
                mul_cmd<=CMD;
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end
           4'b1011: begin
            if(INP_VALID==2'b11) begin
              sum=$signed(OPA)-$signed(OPB);
              RES<=sum;
              OFLOW<=((~OPA[N-1] && ~OPB[N-1]) && sum[N])  || ((OPA[N-1] && OPB[N-1]) && ~sum[N]);
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end
           4'b1100: begin
            if(INP_VALID==2'b11) begin
              diff=$signed(OPA)-$signed(OPB);
              RES<=diff;
              OFLOW<=((OPA[N-1] && ~OPB[N-1]) && ~diff[N]) || ((~OPA[N-1] && OPB[N-1] )&& diff[N]);
            end
            else begin
                RES<=0;
                ERR<=1;
            end
           end

           default:   // For any other case send zero value
            begin
            RES<=0;
            COUT<=0;
            OFLOW<=0;
            G<=0;
            E<=0;
            L<=0;
            ERR<=0;
           end
          endcase
         end

        else          // MODE signal is low, then this is a Logical Operation
        begin 
           RES<=0;
           COUT<=0;
           OFLOW<=0;
           G<=0;
           E<=0;
           L<=0;
           ERR<=0;
           case(CMD)    // CMD is the binary code value of the Logical Operation
             4'b0000: begin  // CMD = 0000: AND
                if(INP_VALID==2'b11) begin
                    RES<=OPA&OPB;   
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0001: // CMD = 0001: NAND
             begin
                if(INP_VALID==2'b11) begin
                    RES<=~(OPA&OPB);   
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0010:// CMD = 0010: OR
             begin
                if(INP_VALID==2'b11) begin
                  RES<=OPA|OPB;   
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0011: // CMD = 0011: NOR
            begin
                if(INP_VALID==2'b11) begin
                  RES<=~(OPA|OPB)  ;   
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0100:// CMD = 0100: XOR
             begin
                if(INP_VALID==2'b11) begin
                    RES<=OPA^OPB ;   
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0101:  // CMD = 0101: XNOR
            begin
                if(INP_VALID==2'b11) begin
                    RES<=~(OPA^OPB);   
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0110:        // CMD = 0110: NOT_A
             begin
                if(INP_VALID==2'b11 ||INP_VALID==2'b01) begin
                    RES<=~OPA;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b0111:        // CMD = 0111: NOT_B
             begin
                if(INP_VALID==2'b11 ||INP_VALID==2'b10) begin
                  RES<=OPB;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b1000:      // CMD = 1000: SHR1_A
             begin
                if(INP_VALID==2'b11 ||INP_VALID==2'b01) begin
                  RES<=OPA>>1;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b1001:      // CMD = 1001: SHL1_A
             begin
                if(INP_VALID==2'b11 ||INP_VALID==2'b01) begin
                  RES<=OPA<<1;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b1010: // CMD = 1010: SHR1_B
             begin
                if(INP_VALID==2'b11 ||INP_VALID==2'b10) begin
                  RES<=OPB>>1;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b1011: // CMD = 1011: SHL1_B
             begin
                if(INP_VALID==2'b11 ||INP_VALID==2'b10) begin
                  RES<=OPB<<1;
                end
                else begin
                    RES<=0;
                    ERR<=1;
                end
             end
             4'b1100:                        // CMD = 1100: ROL_A_B
                  begin
                        if (INP_VALID == 2'b11)
                        begin
                            if (|OPB[(N-1):(N/2)]) begin
                                ERR <= 1'b1;
                            end
                                
                            else begin
                                RES <= {{N{1'b0}}, (OPA << OPB[$clog2(N)-1:0]) | (OPA >> (N - OPB[$clog2(N)-1:0]))};
                            end
                        end
             else begin
                RES<=0;
                ERR<=1;
             end
             end
             4'b1101:                        // CMD = 1101: ROR_A_B 
             begin
                 if (INP_VALID == 2'b11)
                        begin
                          if (|OPB[(N-1):(N/2)]) begin
                                ERR <= 1'b1;
                          end
                          else begin
                                RES <= {{N{1'b0}}, (OPA << OPB[$clog2(N)-1:0]) | (OPA >> (N - OPB[$clog2(N)-1:0]))};
                          end
                        end

        
             else
             begins
                RES<=0;
                ERR<=1;
             end
             end
             default:    // For any other case send high impedence value
               begin
               RES<=RES;
               COUT<=0;
               OFLOW<=0;
               G<=0;
               E<=0;
               L<=0;
               ERR<=0;
               end
          endcase
     end
    end
   end
endmodule

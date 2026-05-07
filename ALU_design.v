`default_nettype none
module ALU_design #(parameter N = 4)(
    input wire CLK,
    input wire RST,
    input wire CE,//clk enable
    input wire MODE,//mode of operation(1=arithmetic 0=logical)
    input wire CIN,//carry input
    input wire [3:0] CMD,//which operation 
    input wire [1:0] INP_VALID,//input valid
    input wire [N-1:0] OPA,
    input wire [N-1:0] OPB,
    output reg ERR,//error flag
    output reg [2*N:0] RES,//result
    output reg OFLOW,
    output reg COUT,
    output reg G,//OPA greater than OPB
    output reg E,//OPA equal to OPB
    output reg L //OPA less than OPB 
);

reg [N-1:0] OPA_1;
reg [N-1:0] OPB_1;
reg [3:0] CMD_1;

reg [N:0] sum;
reg [N:0] diff;

reg mul_active;
reg [3:0] mul_CMD;
reg mul_count;
reg [2*N-1:0] temp_mul;

always @(posedge CLK or posedge RST ) begin
    OPA_1<=OPA;
    OPB_1<=OPB;
    CMD_1<=CMD;
    if(RST) begin //reset all the output
        RES<=0;
        COUT<=0;
        ERR<=0;
        OFLOW<=0;
        G<=0;
        E<=0;
        L<=0;
    end
    else if (CE) begin //checking for clock enable
                  if(mul_active)  //for multiplication making the result to appear at 3rd clk cycle
         begin
            if(INP_VALID!=2'b11) begin //if Input is inlvalid ERR=1
                RES<=0;
                ERR<=1;
                mul_active<=0;
                mul_count<=0;
            end
            else if(CMD!=mul_CMD) begin // if CMD!=mul(4'b1001 or 4'b1010)
                mul_active<=0;
                mul_count<=0;
                RES<=RES;
            end
            else // if input is valid and mul_CMD is also high 
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
    else if(MODE) begin
         RES<=0;
         ERR<=0;
         G<=0;
         E<=0;
         L<=0;
         COUT<=0;
         OFLOW<=0;
         case(INP_VALID) 
         2'b00: begin //both OPA and OPB not valid
            RES<=0;
            ERR<=1;
         end
         2'b01: begin //only when OPA is valid
            case(CMD_1) 
            4'b000: begin
                RES<=0;
                ERR<=1;
            end
            4'b0001: begin
                RES<=0;
                ERR<=1;
            end
            4'b0010: begin
                RES<=0;
                ERR<=1;
            end
            4'b0011:begin
                RES<=0;
                ERR<=1;
            end
            4'b0100: begin
                RES<={1'b0,OPA_1}+1;
                COUT<=({1'b0,OPA_1}+1'b1)>>N; 
                ERR<=0;
            end
            4'b0101: begin
                RES<={1'b0,OPA_1}-1;
                OFLOW<=(OPA_1<1'b1)? 1'b1: 1'b0; 
                ERR<=0;
            end
            4'b0110: begin
                RES<=0;
                ERR<=1;
            end
            4'b0110: begin
                RES<=0;
                ERR<=1;
            end
            4'b1000: begin
                RES<=0;
                ERR<=1;
            end
            4'b1001: begin
                RES<=0;
                ERR<=1;
            end
            4'b1010: begin
                RES<=0;
                ERR<=1;
            end
            4'b1011: begin
                RES<=0;
                ERR<=1;
            end
            4'b1100: begin
                RES<=0;
                ERR<=1;
            end
            default: begin
                RES<=RES;
            end
            endcase
         end
         2'b10: begin //ONLY OPB IS VALID
            case(CMD_1) 
            4'b000: begin
                RES<=0;
                ERR<=1;
            end
            4'b0001: begin
                RES<=0;
                ERR<=1;
            end
            4'b0010: begin
                RES<=0;
                ERR<=1;
            end
            4'b0011:begin
                RES<=0;
                ERR<=1;
            end
            4'b0100: begin
                RES<=0;
                ERR<=1;
            end
            4'b0101: begin
                RES<=0;
                ERR<=1;
            end
            4'b0110: begin
                RES<={1'b0,OPB_1}+1;
                COUT<=({1'b0,OPB_1}+1'b1)>>N;   
                ERR<=0;
            end
            4'b0110: begin
                RES<={1'b0,OPB_1}-1;
                OFLOW<=(OPB_1<1'b1)? 1'b1: 1'b0; 
                ERR<=0;
            end
            4'b1000: begin
                RES<=0;
                ERR<=1;
            end
            4'b1001: begin
                RES<=0;
                ERR<=1;
            end
            4'b1010: begin
                RES<=0;
                ERR<=1;
            end
            4'b1011: begin
                RES<=0;
                ERR<=1;
            end
            4'b1100: begin
                RES<=0;
                ERR<=1;
            end
            default: begin
                RES<=RES;
            end
            endcase   
         end
         2'b11:
         case(CMD_1) 
            4'b000: begin//ADDITION
                RES<=OPA_1+OPB_1;
                ERR<=0;
                COUT<=({1'b0,OPA_1}+{1'b0,OPB_1})>>N;
            end
            4'b0001: begin //SUBTRACTION
                RES<=OPA_1-OPB_1;
                OFLOW<=(OPA_1<OPB_1)? 1'b1: 1'b0;//if OPA_1 IS less than OPB_1 then it will overflow
                ERR<=0;
            end
            4'b0010: begin //ADDITION WITH CIN
                RES<=OPA_1+OPB_1+CIN;
                COUT<=({1'b0,OPA_1}+{1'b0,OPB_1}+CIN)>>N;
                ERR<=1;
            end
            4'b0011:begin //SUBTRACTION WITH CIN
                RES<=OPA_1-OPB_1-CIN;
                OFLOW<=(OPA_1<OPB_1)? 1'b1: 1'b0;
                ERR<=1;
            end
            4'b0100: begin //INCREMENT A
                RES<={1'b0,OPA_1}+1;
                COUT<=({1'b0,OPA_1}+1'b1)>>N;   
                ERR<=0;
            end
            4'b0101: begin //DECREMENT A
                RES<={1'b0,OPA_1}-1;
                OFLOW<=(OPB_1<1'b1)? 1'b1: 1'b0; 
                ERR<=0;
            end
            4'b0110: begin//INCREMENT B
                RES<={1'b0,OPB_1}+1;
                COUT<=({1'b0,OPB_1}+1'b1)>>N;   
                ERR<=0;
            end
            4'b0110: begin //DECREMENT B
                RES<={1'b0,OPB_1}-1;
                OFLOW<=(OPB_1<1'b1)? 1'b1: 1'b0; 
                ERR<=0;
            end
            4'b1000: begin
                RES<=0;
                if(OPA_1<OPB_1) begin
                    G<=0;
                    E<=0;
                    L<=1;
                end
                else if(OPA_1==OPB_1) begin
                    G<=0;
                    E<=1;
                    L<=0;
                end
                else if(OPA_1>OPB_1) begin
                    G<=1;
                    E<=0;
                    L<=0;
                end
                else begin
                    G<=0;
                    E<=0;
                    L<=0;
                end
                ERR<=0;
            end
            4'b1001: begin
                OPA_1<=OPA+1;
                OPB_1<=OPB+1;
                temp_mul<=(OPA+1)*(OPB+1);
                mul_count<=0;
                mul_active<=1;
                mul_CMD<=CMD;
                ERR<=0;
            end
            4'b1010: begin
                OPA_1<=OPA<<1;
                temp_mul<=(OPA<<1)*OPB;
                mul_count<=0;
                mul_active<=1;
                mul_CMD<=CMD;
                ERR<=0;
            end
            4'b1011: begin
                sum=$signed(OPA)-$signed(OPB);
                RES<=sum;
                OFLOW<=(~OPA[N] && ~OPB[N]&& sum[N])  || (OPA[N] && OPB[N]&& ~sum[N]);
                ERR<=0;
            end
            4'b1100: begin
                diff=$signed(OPA)-$signed(OPB);
                RES<=diff;
                OFLOW<=(OPA_1[N] && ~OPB_1[N] && ~diff[N]) || (~OPA_1[N] && OPB_1[N] && diff[N]);
                ERR<=0;
            end
            default: begin
                RES<=RES;
            end
            endcase
         default: RES<=RES;
         endcase
    end
    else begin
         RES<=0;
         ERR<=0;
         G<=0;
         E<=0;
         L<=0;
         COUT<=0;
         OFLOW<=0;
         case(INP_VALID) 
         2'b00: begin //both OPA and OPB not valid
            RES<=0;
            ERR<=1;
         end
         2'b01: begin //Only OPA is valid
            case(CMD_1)
            4'b0000: begin//AND
                RES<=0;
                ERR<=1;
            end
            4'b0001: begin//NAND
                RES<=0;
                ERR<=1;
            end
            4'b0010: begin//OR
                RES<=0;
                ERR<=1;
            end
            4'b0011: begin//NOR
                RES<=0;
                ERR<=1;
            end
            4'b0100: begin//XOR
                RES<=0;
                ERR<=1;
            end
            4'b0101: begin//XNOR
                RES<=0;
                ERR<=1;
            end
            4'b0110: begin //NOT A
                RES<=~OPA;
                ERR<=0;
            end
            4'b0111: begin//NOT B
                RES<=0;
                ERR<=1;
            end
            4'b1000: begin //shift RIGHT A
                RES<=OPA>>1;
                ERR<=0;
            end
            4'b1001: begin //shift LEFT A
                RES<=OPA<<1;
            end
            4'b1010: begin  //shift RIGHT B
                RES<=0;
                ERR<=1;
            end
            4'b1011: begin ///shift LEFT B
                RES<=0;
                ERR<=1;
            end
            4'b1100: begin
                RES<=0;
                ERR<=1;
            end
            4'b1101: begin
                RES<=0;
                ERR<=1;
            end
            default: RES<=RES;
            endcase
         end
         2'b10: begin //Only OPBB is valid
            case(CMD_1)
            4'b0000: begin//AND
                RES<=0;
                ERR<=1;
            end
            4'b0001: begin//NAND
                RES<=0;
                ERR<=1;
            end
            4'b0010: begin//OR
                RES<=0;
                ERR<=1;
            end
            4'b0011: begin//NOR
                RES<=0;
                ERR<=1;
            end
            4'b0100: begin//XOR
                RES<=0;
                ERR<=1;
            end
            4'b0101: begin//XNOR
                RES<=0;
                ERR<=1;
            end
            4'b0110: begin //NOT A
                RES<=0;
                ERR<=1;
            end
            4'b0111: begin//NOT B
                RES<=~OPB_1;
                ERR<=0;
            end
            4'b1000: begin //shift RIGHT A
                RES<=0;
                ERR<=1;
            end
            4'b1001: begin //shift LEFT A
                RES<=0;
                ERR<=1;
            end
            4'b1010: begin  //shift RIGHT B
                RES<=OPB_1>>1;
                ERR<=0;
            end
            4'b1011: begin ///shift LEFT B
                RES<=OPB_1<<1;
                ERR<=0;
            end
            4'b1100: begin
                RES<=0;
                ERR<=1;
            end
            4'b1101: begin
                RES<=0;
                ERR<=1;
            end
            default: RES<=RES;
            endcase
         end 
         2'b11: begin //both are valid
            case(CMD_1)
            4'b0000: begin//AND
                RES<=OPA&OPB_1;
                ERR<=0;
            end
            4'b0001: begin//NAND
                RES<=~(OPA&OPB_1);
                ERR<=0;
            end
            4'b0010: begin//OR
                RES<=OPA|OPB_1;
                ERR<=0;
            end
            4'b0011: begin//NOR
                RES<=~(OPA|OPB_1);
                ERR<=0;
            end
            4'b0100: begin//XOR
                RES<=OPA^OPB_1;
                ERR<=0;
            end
            4'b0101: begin//XNOR
                RES<=~(OPA^OPB_1);
                ERR<=0;
            end
            4'b0110: begin //NOT A
                RES<=~OPA;
                ERR<=0;
            end
            4'b0111: begin//NOT B
                RES<=~OPB_1;
                ERR<=0;
            end
            4'b1000: begin //shift RIGHT A
                RES<=0;
                ERR<=1;
            end
            4'b1001: begin //shift LEFT A
                RES<=0;
                ERR<=1;
            end
            4'b1010: begin  //shift RIGHT B
                RES<=OPB_1>>1;
                ERR<=1;
            end
            4'b1011: begin ///shift LEFT B
                RES<=OPB_1<<1;
                ERR<=0;
            end
            4'b1100: begin //ROL OPA OPB_1 times
                if (|OPB_1[(N-1):(N/2)]) begin
                    ERR <= 1'b1;
                end
                                
                else begin
                    RES <= {{N{1'b0}}, (OPA << OPB_1[$clog2(N)-1:0]) | (OPA >> (N - OPB_1[$clog2(N)-1:0]))};
                end
                ERR<=1;
            end
            4'b1101: begin //ROR OPA OPB_1 times
                if (|OPB_1[(N-1):(N/2)]) begin
                    ERR <= 1'b1;
                end
                else begin
                    RES <= {{N{1'b0}}, (OPA << OPB_1[$clog2(N)-1:0]) | (OPA >> (N - OPB_1[$clog2(N)-1:0]))};
                end
                ERR<=0;
            end
            default: RES<=RES;
            endcase
            
         end
         default:RES<=RES;
         endcase        
    end
    end
end
endmodule

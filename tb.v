`timescale 1ns / 1ps 
module tb_lock(); 
reg clk;
reg clr;         
reg cancel;       //取消键'*'
reg [3:0] din;   //数字键
reg confirm;     //确定键'#'
wire unlock_ok;  //开锁,输出1
wire reset_ok;   //成功重设密码，输出1
wire locking;    //输错密码锁定状态,输出1

initial begin
	clk <= 0; 
    confirm <= 0;
    din <= 0;
    cancel <= 0;
    clr <= 1;
    #30
    clr <= 0;
    
    //依次输入 1 2 3 4 确认,成功开锁
    din <= 1;
    #20
    din <= 2;
    #20  
    din <= 3;
    #20  
    din <= 4;
    #20  
    din <= 0;
    confirm <= 1;

    #20
    confirm <= 0;
    #20
    #20
    #20
    #20

    //依次输入 1 2 3 5 确认,无法开锁
    din <= 1;
    #20
    din <= 2;
    #20
    din <= 3;
    #20
    din <= 5;
    #20  
    din <= 0;
    confirm <= 1;


    #20
    confirm <= 0;
    din <= 1;
    #20
    din <= 0;
    #20
    #20
    #20
    #20


    //依次输入 230419 230419 6789 6789 确认 
    //密码从默认的1234 修改为 6789
    din <= 2; #20
    din <= 3; #20
    din <= 0; #20
    din <= 4; #20
    din <= 1; #20
    din <= 9; #20
    din <= 2; #20
    din <= 3; #20
    din <= 0; #20
    din <= 4; #20
    din <= 1; #20
    din <= 9; #20
    din <= 6; #20
    din <= 7; #20
    din <= 8; #20
    din <= 9; #20
    din <= 6; #20
    din <= 7; #20
    din <= 8; #20
    din <= 9; #20
    confirm <= 1; #20
    confirm <= 0; din <= 0; #20


    //连续输入3次错误密码：
    //1234 # 1234 # 1234 #
    din <= 1; confirm <= 0; #20
    din <= 2; #20
    din <= 3; #20
    din <= 4; #20
    din <= 0; confirm <= 1; #20
    din <= 1; confirm <= 0; #20
    din <= 2; #20
    din <= 3; #20
    din <= 4; #20
    din <= 0; confirm <= 1; #20 
    din <= 1; confirm <= 0; #20
    din <= 2; #20
    din <= 3; #20
    din <= 4; #20
    din <= 0; confirm <= 1; #20

    //连续输错三次后，进入lock状态，无法开锁
    din <= 6; confirm <= 0; #20
    din <= 7; #20
    din <= 8; #20
    din <= 9; #20
    din <= 0; confirm <= 1; #20

    //中途取消test
    din <= 6; confirm <= 0; #20
    din <= 7; #20
    din <= 8; #20
    cancel <= 1; din <= 0; #20
    din <= 9; cancel <= 0; #20
    din <= 0; confirm <= 1; #20
    confirm <= 0;


end

//生成时钟，模拟晶振实际的周期时序
always #10 clk = ~clk;  //每10ns，sys_clk进行翻转，达到模拟晶振周期为20ns
 

lock test_lock(   
	.clk(clk),
    .clr(clr),
    .din(din),
    .confirm(confirm),
    .cancel(cancel),
    .unlock_ok(unlock_ok),
    .reset_ok(reset_ok),
    .locking(locking)
);

endmodule

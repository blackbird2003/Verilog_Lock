`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UESTC
// Engineer: blackbird
// 
// Create Date: 2023/05/26 09:15:33
// Design Name: lock
//////////////////////////////////////////////////////////////////////////////////



module lock(
    input wire clk,
    input wire clr,         
    input wire [3:0] din,   //数字键0~9
    input wire confirm,     //确定键'#'
    input wire cancel,      //取消键'*'
    output reg unlock_ok,   //成功开锁状态时,输出1
    output reg reset_ok,    //重设密码成功时,输出1   
    output reg locking      //输错密码3次进入锁定状态时,输出1
);

    //初始密码1234
    reg [3:0] passwd0 = 1;
    reg [3:0] passwd1 = 2;
    reg [3:0] passwd2 = 3;
    reg [3:0] passwd3 = 4;

    //超级密码230419
    reg [3:0] superwd0 = 2;
    reg [3:0] superwd1 = 3;
    reg [3:0] superwd2 = 0;
    reg [3:0] superwd3 = 4;
    reg [3:0] superwd4 = 1;
    reg [3:0] superwd5 = 9;

    //新密码
    reg [3:0] newpasswd0 = 0, newpasswd1 = 0, newpasswd2 = 0, newpasswd3 = 0;

    //开启状态保持时间
    reg [5:0] open_time = 0;
    //连续输错密码次数
    reg [5:0] wrong_count = 0;
    //锁定状态保持时间
    reg [5:0] lock_time = 0;

    //状态定义
    reg[3:0] present_state_s, next_state_s;
    parameter S0 = 3'b0, S1 = 3'b1, S2 = 3'b10, S3 = 3'b11;
    parameter S4 = 3'b100;      //等待键入确定键'#'
    parameter Open = 3'b101;    //开启状态
    parameter Lock = 3'b110;    //输错3次密码,锁定状态
    
    //状态切换与输出
    always @(posedge clk or posedge clr) begin

        if (open_time > 0) begin
            if (open_time == 1) unlock_ok <= 0;
            open_time <= open_time - 1;
        end

        if (lock_time > 0) begin
            if (lock_time == 1) begin
                locking <= 0;
                wrong_count <= 0;
            end
            lock_time <= lock_time - 1;
        end

        if (clr == 1) begin
            present_state_s <= S0;
            unlock_ok <= 0;
            locking <= 0;
        end
        else 
            begin
                if (present_state_s != Open && next_state_s == Open) begin
                    unlock_ok <= 1;
                    open_time <= 3;
                end
                if (present_state_s != Lock && next_state_s == Lock) begin
                    locking <= 1;
                    lock_time <= 3;
                end
                present_state_s <= next_state_s;
            end
    end


   

    //状态机S
    always @(*) begin
        case (present_state_s)
            S0: 
            begin
                if (din == passwd0)   next_state_s <= S1;
                else next_state_s <= S0;

                if (confirm == 1) 
                begin
                    wrong_count = wrong_count + 1;
                    if (wrong_count >= 3)  
                    begin
                        next_state_s <= Lock;
                    end
                    else 
                        next_state_s <= S0;
                end
                if (cancel == 1) next_state_s <= S0;
            end
            S1: 
            begin
                if (din == passwd1)   next_state_s <= S2;
                else next_state_s <= S0;

                if (confirm == 1) 
                begin
                    wrong_count <= wrong_count + 1;
                    if (wrong_count >= 3)   
                    begin
                        next_state_s <= Lock;
                    end
                    else 
                        next_state_s <= S0;
                end
                if (cancel == 1) next_state_s <= S0;
            end
            S2: 
            begin
                if (din == passwd2)   next_state_s <= S3;
                else next_state_s <= S0;
                if (confirm == 1) 
                begin
                    wrong_count <= wrong_count + 1;
                    if (wrong_count >= 3)   
                    begin
                        next_state_s <= Lock;
                    end
                    else 
                        next_state_s <= S0;
                end
                if (cancel == 1) next_state_s <= S0;
            end
            S3: 
            begin
                if (din == passwd3)   next_state_s <= S4;
                else next_state_s <= S0;

                if (confirm == 1) 
                begin
                    wrong_count <= wrong_count + 1;
                    if (wrong_count >= 3)   
                    begin
                        next_state_s <= Lock;
                    end
                    else 
                        next_state_s <= S0;
                end
                if (cancel == 1) next_state_s <= S0;
            end
            S4: 
            begin 
                if (confirm == 1) begin
                    next_state_s <= Open;
                    wrong_count <= 0;
                end
                else 
                    next_state_s <= S0;
                    
            end
            Open:
            begin
                if (open_time > 0) 
                    next_state_s <= Open;
                else 
                    next_state_s = S0;
            end
            Lock:
            begin
                if (lock_time > 0)
                begin
                    next_state_s <= Lock;
                end
                else next_state_s = S0;
            end
        endcase
    end



    reg[5:0] present_state_t, next_state_t;
    parameter T0 = 5'b0, T1 = 5'b1, T2 = 5'b10, T3 = 5'b11, T4 = 5'b100, T5 = 5'b101, 
    T6 = 5'b110, T7 = 5'b111, T8 = 5'b1000, T9 = 5'b1001, T10 = 5'b1010, T11 = 5'b1011, 
    T12 = 5'b1100, T13 = 5'b1101, T14 = 5'b1110, T15 = 5'b1111, 
    T16 = 5'b10000, T17 = 5'b10001, T18 = 5'b10010, T19 = 5'b10011, 
    T20 = 5'b10100, //等待键入确定键'#'
    OK = 5'b10101; 

    always @(posedge clk or posedge clr) begin
        if (clr == 1)
            present_state_t <= T0;
        else 
            present_state_t <= next_state_t;
    end
    //状态机T
    always @(*) begin
        case (present_state_t)
            T0: if (din == superwd0)   next_state_t <= T1;
                else next_state_t <= T0;
            T1: if (din == superwd1)   next_state_t <= T2;
                else next_state_t <= T0;
            T2: if (din == superwd2)   next_state_t <= T3;
                else next_state_t <= T0;
            T3: if (din == superwd3)   next_state_t <= T4;
                else next_state_t <= T0;
            T4: if (din == superwd4)   next_state_t <= T5;
                else next_state_t <= T0;
            T5: if (din == superwd5)   next_state_t <= T6;
                else next_state_t <= T0;
            T6: if (din == superwd0)   next_state_t <= T7;
                else next_state_t <= T0;
            T7: if (din == superwd1)   next_state_t <= T8;
                else next_state_t <= T0;
            T8: if (din == superwd2)   next_state_t <= T9;
                else next_state_t <= T0;
            T9: if (din == superwd3)   next_state_t <= T10;
                else next_state_t <= T0;
            T10: if (din == superwd4)   next_state_t <= T11;
                else next_state_t <= T0;
            T11: if (din == superwd5)   next_state_t <= T12;
                else next_state_t <= T0;
            T12:
                begin
                newpasswd0 <= din; next_state_t <= T13;
                end
            T13:
                begin
                newpasswd1 <= din; next_state_t <= T14;
                end
            T14:
                begin
                newpasswd2 <= din; next_state_t <= T15;
                end
            T15:
                begin
                newpasswd3 <= din; next_state_t <= T16;
                end
            T16:
                if (din == newpasswd0)   next_state_t <= T17;
                else next_state_t <= T0;
            T17:
                if (din == newpasswd1)   next_state_t <= T18;
                else next_state_t <= T0;
            T18:
                if (din == newpasswd2)   next_state_t <= T19;
                else next_state_t <= T0;
            T19:
                if (din == newpasswd3)   next_state_t <= T20;
                else next_state_t <= T0;
            T20:
                if (confirm == 1)  begin
                    next_state_t <= OK;
                end
                else next_state_t <= T0;
            OK:
                begin
                passwd0 <= newpasswd0;
                passwd1 <= newpasswd1;
                passwd2 <= newpasswd2;
                passwd3 <= newpasswd3;
                next_state_t <= T0;
                wrong_count <= 0;//重设密码后，重新计算连续输错的次数
                end
            default: next_state_t <= T0;
        endcase
        if (cancel == 1) next_state_t <= T0;
    end

    always @(posedge clk or posedge clr) begin
        if (clr == 1) reset_ok <= 0;
        else 
            if (present_state_t == OK)
                reset_ok <= 1;
            else 
                reset_ok <= 0;
    end
endmodule





//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+



extern int MagicNumber = 10003;
extern int MA_period = 200;
extern double upper = 0.5;
extern double bottom = 0.5;
extern int t = 0; //何本更新されたら強制決済するか
extern double Lots = 0.1;
extern double StopLoss = 0.2; //+per cent
extern int Slippage = 3;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
//datetime time = 0;
datetime time2 = 0;
int mode = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(){
//バーが更新された場合のみ実行
//if(time != Time[0]) {

////買い条件
//   if(Ask < iMA(NULL,PERIOD_M15,MA_period,0,MODE_EMA,PRICE_CLOSE,1)*(1-bottom/100)){
//      mode = 1;
//     }
////売り条件
//   if(Bid > iMA(NULL,PERIOD_M15,MA_period,0,MODE_EMA,PRICE_CLOSE,1)*(1+upper/100)){
//      mode = 2;
//     }

   //time = Time[0]; //バーの開始時刻

//}

//注文
   if(TotalOrdersCount()== 0){
      int result = 0;
      double TheStopLoss = 0;

      //買い注文
      if(Ask < iMA(NULL,PERIOD_M15,MA_period,0,MODE_EMA,PRICE_CLOSE,1)*(1-bottom/100)){

         if(StopLoss > 0){
            TheStopLoss = Ask*(1-StopLoss/100);
           }
         else{
            TheStopLoss = 0;
           }
         result = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,NormalizeDouble(TheStopLoss,Digits),0,NULL,MagicNumber,0,Blue);
         Print("新規注文");
        }
      //売り注文
      if(Bid > iMA(NULL,PERIOD_M15,MA_period,0,MODE_EMA,PRICE_CLOSE,1)*(1+upper/100)){

         if(StopLoss > 0){
            TheStopLoss = Bid*(1+StopLoss/100);
           }
         else{
            TheStopLoss = 0;
           }
         result = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,NormalizeDouble(TheStopLoss,Digits),0,NULL,MagicNumber,0,Red);
         Print("新規注文");
        }

      if(result > 0){
         mode = 0;
         time2 = Time[0];
         Print("約定しました");
        }
      else{
         Print("約定しませんでした Error:",GetLastError());
        }
     }

//決済
   for(int cnt=0; cnt<OrdersTotal(); cnt++){
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){

         if(OrderType()== OP_BUY){
            if((Bid > iMA(NULL,PERIOD_M15,MA_period,0,MODE_EMA,PRICE_CLOSE,1)) || (t != 0 && Time[t] > time2)){
               if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Blue)){
                  Print("決済注文");
                 }
               else{
                  Print("決済できませんでした");
                 }
              }
           }
         else{
            if((Ask < iMA(NULL,PERIOD_M15,MA_period,0,MODE_EMA,PRICE_CLOSE,1)) || (t != 0 && Time[t] > time2)){
               if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red)){
                  Print("決済注文");
                 }
               else{
                  Print("決済できませんでした");
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalOrdersCount(){
   int result=0;
   for(int i=0; i<OrdersTotal(); i++){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==MagicNumber) result++;
     }
   return (result);
  }

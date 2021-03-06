


extern int MagicNumber = 10002;
extern int MA_period1 = 20;
extern int MA_period2 = 60;
extern int shift = 1;
extern int t = 0; //何本更新されたら強制決済するか
extern double Lots = 0.1;
extern double StopLoss = 0.2; //+per cent
extern double TakeProfit = 0.6; //+per cent
extern double TrailingStop = 0; //+per cent
extern bool OnlyBuy = false;
extern bool OnlySell = false;
extern int Slippage = 3;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
datetime time = 0;
datetime time2 = 0;
int mode = 0;
int mode2 = 0;

void OnTick(){
 //バーが更新された場合のみ実行
 if(time != Time[0]) {
   
     //Print("TotalOrdersCount ",TotalOrdersCount());
     //Print("mode ",mode);
     //Print(iMA(NULL,PERIOD_CURRENT,MA_period1,shift,MODE_EMA,PRICE_CLOSE,1),iMA(NULL,PERIOD_CURRENT,MA_period2,shift,MODE_EMA,PRICE_CLOSE,1));
     //Print("time ",time," time2 ",time2);
  if(OnlySell == false){
        if((iMA(NULL,PERIOD_CURRENT,MA_period1,shift,MODE_EMA,PRICE_CLOSE,1)>iMA(NULL,PERIOD_CURRENT,MA_period2,shift,MODE_EMA,PRICE_CLOSE,1)) 
        && (iMA(NULL,PERIOD_CURRENT,MA_period1,shift,MODE_EMA,PRICE_CLOSE,2)<iMA(NULL,PERIOD_CURRENT,MA_period2,shift,MODE_EMA,PRICE_CLOSE,2))){
        mode = 1;
        mode2 = 1;
        }
     }   
  if(OnlyBuy == false){   
        if((iMA(NULL,PERIOD_CURRENT,MA_period2,shift,MODE_EMA,PRICE_CLOSE,1)>iMA(NULL,PERIOD_CURRENT,MA_period1,shift,MODE_EMA,PRICE_CLOSE,1)) 
        && (iMA(NULL,PERIOD_CURRENT,MA_period2,shift,MODE_EMA,PRICE_CLOSE,2)<iMA(NULL,PERIOD_CURRENT,MA_period1,shift,MODE_EMA,PRICE_CLOSE,2))){
        mode = 2;
        mode2 = 2;
        }
     }
     time = Time[0]; //バーの開始時刻  
     
  }
     
  //注文
  if( TotalOrdersCount()== 0 ){
     int result = 0;
     double TheStopLoss = 0;
     double TheTakeProfit = 0;
     
  
     //買い注文
     if(mode == 1){
     
        //損切、利確をPips単位で表現し直す
        if(TakeProfit > 0){
            TheTakeProfit = Ask*(1+TakeProfit/100);
        }else{
            TheTakeProfit = 0;
        }
        if(StopLoss > 0){
            TheStopLoss = Ask*(1-StopLoss/100);
        }else{
            TheStopLoss = 0;
        }
       result = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),NULL,MagicNumber,0,Blue);
       Print("新規注文");
     } 
     //売り注文
     if(mode == 2){
     
        //損切、利確をPips単位で表現し直す
        if(TakeProfit > 0){
            TheTakeProfit = Bid*(1-TakeProfit/100);
        }else{
            TheTakeProfit = 0;
        }
        if(StopLoss > 0){
            TheStopLoss = Bid*(1+StopLoss/100);
        }else{
            TheStopLoss = 0;
        }
       result = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),NULL,MagicNumber,0,Red);
       Print("新規注文");
     }
     
     if(result > 0){
       mode = 0;
       time2 = Time[0];
     }else{
       Print("約定しませんでした Error:",GetLastError());
     }
  }
  
  //決済
  for(int cnt=0;cnt<OrdersTotal();cnt++){
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     
     if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber){
         
         if(OrderType()== OP_BUY){
            if((mode2 == 2) || (t != 0 && Time[t] == time2)){
               if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Blue)){
                  Print("決済注文");
                  mode2 = 0;
               }else{
                  Print("決済できませんでした");
               }
            }
            if(TrailingStop > 0){                 
               if(Bid > OrderOpenPrice()*(1+TrailingStop/100)){
                  if((OrderStopLoss() < Bid*(1-TrailingStop/100)) || (OrderStopLoss() == 0)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid*(1-TrailingStop/100),OrderTakeProfit(),0,Green);
                  }
               }
            }
         }else{
            if((mode2 == 1) || (t != 0 && Time[t] == time2)){
                if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red)){
                   Print("決済注文");
                   mode2 = 0;
                }else{
                   Print("決済できませんでした");
                }
            }
            if(TrailingStop > 0){                 
               if(Ask < OrderOpenPrice()*(1-TrailingStop/100)){
                  if((OrderStopLoss() > Ask*(1+TrailingStop/100)) || (OrderStopLoss() == 0)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask*(1+TrailingStop/100),OrderTakeProfit(),0,Green);
                  }
               }
            }
         }
     }
  }      
}

int TotalOrdersCount(){
  int result=0;
  for(int i=0;i<OrdersTotal();i++){
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber) result++;
  }
  return (result);
}

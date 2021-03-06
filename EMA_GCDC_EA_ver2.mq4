


extern int MagicNumber=10002;
extern int MA_period1=20;
extern int MA_period2=60;
extern int shift=1;
extern double Lots =0.1;
extern double StopLoss=0.2; //+per cent
extern double TakeProfit=0.6; //+per cent
extern double TrailingStop=0; //+per cent
extern int Slippage=3;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
datetime time =0;
int mode = 0;
void OnTick()
{
 //バーが更新された場合のみ実行
 if(time != Time[0]) {
  
  
  //double MyPoint=Point;
  //if(Digits==3 || Digits==5) MyPoint=Point*10;
  
  double TheStopLoss=0;
  double TheTakeProfit=0;
  if( TotalOrdersCount()==0 ) 
  {
     int result=0;
     if((iMA(NULL,PERIOD_M15,MA_period1,shift,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,MA_period2,shift,MODE_EMA,PRICE_CLOSE,0)) 
     && (iMA(NULL,PERIOD_M15,MA_period1,shift,MODE_EMA,PRICE_CLOSE,1)<iMA(NULL,PERIOD_M15,MA_period2,shift,MODE_EMA,PRICE_CLOSE,1))){
     mode = 1;
     }
     
     if(mode == 1){
        result=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,NULL,MagicNumber,0,Blue);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Ask*(1+TakeProfit/100); //Modified
         if(StopLoss>0) TheStopLoss=Ask*(1-StopLoss/100); //Modified
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
         mode = 0;
        }else{
         Print("約定しませんでした Error:",GetLastError());
        }
        return(0);
     }
     if((iMA(NULL,PERIOD_M15,MA_period2,shift,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,MA_period1,shift,MODE_EMA,PRICE_CLOSE,0)) 
     && (iMA(NULL,PERIOD_M15,MA_period2,shift,MODE_EMA,PRICE_CLOSE,1)<iMA(NULL,PERIOD_M15,MA_period1,shift,MODE_EMA,PRICE_CLOSE,1))){
     mode = 2;
     }
     
     if(mode == 2){
        result=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,NULL,MagicNumber,0,Red);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Bid*(1-TakeProfit/100); //Modified
         if(StopLoss>0) TheStopLoss=Bid*(1+StopLoss/100); //Modified
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
         mode = 0;
        }else{
         Print("約定しませんでした Error:",GetLastError());
        }
        return(0);
     }
  }else{
  time = Time[0]; //バーの開始時刻
  }
 
   
  for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber 
         )  
        {
         if(OrderType()==OP_BUY)  
           {
              if((iMA(NULL,PERIOD_M15,MA_period2,shift,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,MA_period1,shift,MODE_EMA,PRICE_CLOSE,0))) //close buy rule
              {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
              }
            if(TrailingStop>0)  
              {                 
               if(Bid>OrderOpenPrice()*(1+TrailingStop/100)) //Modified
                 {
                  if((OrderStopLoss()<Bid*(1-TrailingStop/100)) || (OrderStopLoss()==0)) //Modified
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid*(1-TrailingStop/100),OrderTakeProfit(),0,Green); //Modified
                     return(0);
                    }
                 }
              }
           }
         else 
           {
                if((iMA(NULL,PERIOD_M15,MA_period1,shift,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,MA_period2,shift,MODE_EMA,PRICE_CLOSE,0))) //close sell rule
                {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                }
            if(TrailingStop>0)  
              {                 
               if(Ask<OrderOpenPrice()*(1-TrailingStop/100)) //Modified
                 {
                  if((OrderStopLoss()>Ask*(1+TrailingStop/100)) || (OrderStopLoss()==0)) //Modified
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask*(1+TrailingStop/100),OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
     }
 }
   //20088351
   return(0);
}

int TotalOrdersCount()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber) result++;

   }
  return (result);
}

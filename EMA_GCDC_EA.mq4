


extern int MagicNumber=10001;
extern double Lots =0.1;
extern double StopLoss=0.2; //+per cent
extern double TakeProfit=0.6; //+per cent
extern int TrailingStop=0; //+per cent
extern int Slippage=3;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
int start()
{
  //double MyPoint=Point;
  //if(Digits==3 || Digits==5) MyPoint=Point*10;
  
  double TheStopLoss=0;
  double TheTakeProfit=0;
  if( TotalOrdersCount()==0 ) 
  {
     int result=0;
     if((iMA(NULL,PERIOD_M15,20,1,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,60,1,MODE_EMA,PRICE_CLOSE,0))) //Buy rule
     {
        result=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,NULL,MagicNumber,0,Blue);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Ask*(1+TakeProfit/100); //Modified
         if(StopLoss>0) TheStopLoss=Ask*(1-StopLoss/100); //Modified
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
        }
        return(0);
     }
     if((iMA(NULL,PERIOD_M15,60,1,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,20,1,MODE_EMA,PRICE_CLOSE,0))) //Sell rule
     {
        result=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,NULL,MagicNumber,0,Red);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Bid*(1-TakeProfit/100); //Modified
         if(StopLoss>0) TheStopLoss=Bid*(1+StopLoss/100); //Modified
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
        }
        return(0);
     }
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
              if((iMA(NULL,PERIOD_M15,60,20,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,20,60,MODE_EMA,PRICE_CLOSE,0))) //close buy rule
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
                if((iMA(NULL,PERIOD_M15,20,1,MODE_EMA,PRICE_CLOSE,0)>iMA(NULL,PERIOD_M15,60,1,MODE_EMA,PRICE_CLOSE,0))) //close sell rule
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

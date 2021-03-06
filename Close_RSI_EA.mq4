


extern int MagicNumber=10001;
extern int Buyline=30;
extern int Sellline=70;
extern double Lots =0.1;
extern double StopLoss=0.6;
extern double TakeProfit=1;
extern int TrailingStop=0;
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
     double rsinow = iRSI(NULL,PERIOD_M15,40,PRICE_CLOSE,0);  // 現時点のRSI値
     double rsiprv = iRSI(NULL,PERIOD_M15,40,PRICE_CLOSE,1);  // 1本前のRSI値
     if((Buyline>rsinow) && (Buyline<rsiprv)) //buy rule
     {
        result=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,NULL,MagicNumber,0,Blue);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Ask*(1+TakeProfit/100);
         if(StopLoss>0) TheStopLoss=Ask*(1-StopLoss/100);
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
        }
        return(0);
     }
     if((Sellline<rsinow) && (Sellline<rsiprv)) //sell rule
     {
        result=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,NULL,MagicNumber,0,Red);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Bid*(1-TakeProfit/100);
         if(StopLoss>0) TheStopLoss=Bid*(1+StopLoss/100);
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
              if((rsinow>Sellline)) //close buy rule
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
                if(rsinow<Buyline) // here is your close sell rule
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

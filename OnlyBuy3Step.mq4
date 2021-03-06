//+------------------------------------------------------------------+
//|                                                AutoTradeTest.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

//inputは変更不可、externは変更可
input int magic_number = 12345; //マジックナンバー
input double lots = 0.1; //ロット
input double stoploss = 0.15; //損切
input double takeprofit = 0.30; //利確
input double trailing =0.0; //トレール
input int spread = 15; //許容スプレッド（ポイント）

input int ma1_period = 20; //短期MA
input int ma2_period = 80; //中期MA
input int ma3_period = 200; //長期MA
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int mode = 0;
datetime time =0;
//double stop = 2/100;
//double profit = 6/100;

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() //ティックごとに実行
  {
//---
   //バリデーション
   if(!(ma1_period < ma2_period && ma2_period < ma3_period)){
      Print("パラメータが不正です。");
      ExpertRemove();
   }
   
   //バーが更新された場合のみ実行
   if(time != Time[0]) {
   
      time = Time[0]; //バーの開始時刻
      //1.下降POを確認 2.上昇POを確認 3.RSIで押しを確認→買いエントリー
      double ma1 = iMA(NULL,PERIOD_CURRENT,ma1_period,0,MODE_SMA,PRICE_CLOSE,1);
      double ma2 = iMA(NULL,PERIOD_CURRENT,ma2_period,0,MODE_SMA,PRICE_CLOSE,1);
      double ma3 = iMA(NULL,PERIOD_CURRENT,ma3_period,0,MODE_SMA,PRICE_CLOSE,1);
            
      if(ma1<ma2 && ma2<ma3){
      //下降PO
      mode = 1;
      }
      
      if(ma1>ma2 && ma2>ma3 && mode==1){
      //上昇PO
         if(mode==1){
         mode = 2;
         }
      }
   }
   
   int total = OrdersTotal(); //待機中＆保有中のポジション数の合計（口座内の全ての数）      
   int position = 0;//このEAのポジション数
   
   //このEAの同通貨ポジションを選択
   if(total>0){
      for(int i=0; i<total; i++){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderMagicNumber() == magic_number && OrderSymbol() == Symbol()){
               
               position++;
               if(OrderType() == OP_BUY){
                  //決済
                  if(OrderOpenPrice()-stoploss >= Bid || OrderOpenPrice()+takeprofit<=Bid){
                     if(!OrderClose(OrderTicket(), OrderLots(), Bid, 0, Red)){
                        Print("クローズできませんでした　Error:", GetLastError());  
                     }
                  //トレール
                  }else if(trailing > 0){
                     if(OrderOpenPrice()+trailing <= Bid && OrderStopLoss() < NormalizeDouble(Bid-trailing,Digits)){
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-trailing, OrderTakeProfit(),OrderExpiration(),Red)){
                           Print("クローズできませんでした　Error:", GetLastError());
                        }
                     }
                  }
               }
            }   
         }
      }   
   }   
   double rsi = iRSI(NULL,PERIOD_CURRENT,ma1_period,PRICE_CLOSE,0);
   if(position==0 && mode==2){
      if(rsi<30 && spread>=MarketInfo(NULL,MODE_SPREAD)){
         //エントリー
         int ticket = OrderSend(NULL,OP_BUY,lots,Ask,3,0,0,NULL,magic_number,0,Red);
         if(ticket < 0){
            Print("約定しませんでした Error:",GetLastError());
         }
      }
   }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                          Synergy_copy_export.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern string Name = "";               //Название копира
extern string Prefix = "";             // Есть ли префикс у валютной пары
extern string Suffix = "";             // Есть ли суффикс у валютной пары
int countP;                            // Подсчет символов в префиксе
int countS;                            // Подсчет символов в суффиксе
int total;                             // Переменная всех ордеров
string sym;                            // Правильное написание символа
bool time;                       // Переменная для подсчета времени

int OnInit()
  {

countP = StringLen(Prefix);            // Посчитал кол-во символов в префиксе
countS = StringLen(Suffix);            // Посчитал кол-во символов в суффиксе

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  if (MathMod(TimeCurrent(),2)==0 && time == true) 
{
time = false;
int handle = FileOpen(Name,FILE_COMMON|FILE_CSV| FILE_WRITE);        // Переменая с номером файла. Открытие файла.


   
total = OrdersTotal();

while (total >0)                                                    // Проверить все ордера
{
total = total - 1;
OrderSelect(total,SELECT_BY_POS); 
sym = StringSubstr(OrderSymbol(),countP);
sym = StringSubstr(sym,0,StringLen(sym) - countS);
                       
FileWrite(handle,sym,OrderOpenPrice(),OrderTakeProfit(),OrderStopLoss(),OrderLots(),OrderTicket(),OrderType());
   
  }
FileClose(handle);
FileCopy(Name,FILE_COMMON,Name+"-2",FILE_REWRITE|FILE_COMMON);
}
else 
time = true;
  }
//+------------------------------------------------------------------+

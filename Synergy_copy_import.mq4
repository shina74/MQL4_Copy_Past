//+------------------------------------------------------------------+
//|                                          Synergy_copy_import.mq4 |
//|                                 Synergy_trade. Шунайлов Валентин |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Synergy_trade. Шунайлов Валентин"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern string Name = "";               //Название копира
extern bool Use_multiply = false;      //Использовать ли свои лоты?
extern double Lot = 0.01;              //Каким лотом открывать (Если использовать свои лоты)
extern double Multiply = 1;            //С каким коэффициэнтом копировать (Если не использовать свои лоты)
extern string Prefix = "";             // Есть ли префикс у валютной пары
extern string Suffix = "";             // Есть ли суффикс у валютной пары
extern int Slippage = 20;              // Какое максимально допустимое отклонение цены открытия от цены открытия ордера на сервере

double vol;                            // Переменная объема для использование в открытии ордера
double slip;                           // Переменная отклонения цены от цены открытия сервера
int total;                             // Переменная количества ордеров
int a;                                 // Переменная для подсчет   
double price;                          // Переменная цены открытия ордера
string t;                              // Переменная для работы проскальзования
bool time;                             // Переменная для подсчета времени

int OnInit()
  {

slip = Slippage;   // Переменная отклонения

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//---                                                    
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
 if (MathMod(TimeCurrent(),2) !=0 && time == true) 
{
time=false;
FileCopy(Name+"-2",FILE_COMMON,Name+"-3",FILE_REWRITE|FILE_COMMON); 
int handle = FileOpen(Name+"-3",FILE_COMMON|FILE_CSV|FILE_READ);        // Переменая с номером файла. Открытие файла.

   while (FileIsEnding(handle) == false)
   {
   
string    ssym =     FileReadString (handle),                        // Выгружаем символ
          sopen =    FileReadString (handle),                        // Выгружаем цену открытия   
          sTP =      FileReadString (handle),                        // Выгружаем ТП
          sSL =      FileReadString (handle),                        // Выгружаем СЛ
          svol =     FileReadString (handle),                        // Выгружаем объем
          stiket =   FileReadString (handle),                        // Выгружаем номер тикета
          stype =    FileReadString (handle);                        // Выгружаем тип сделки
          

total = OrdersTotal();                                               // Всего ордеров
a = 0;                                                               // Переменную для подсчета приводим к нулю

while (total > 0)                                                   // До тех пор пока не проверятся все ордера
{
total = total - 1;
OrderSelect (total,SELECT_BY_POS);                                   // Выбираем ордер
if (StringFind(OrderComment(),stiket,0)>=0 && StringFind(OrderComment(),Name,0)>=0)     // Если в комментарии есть номер тикета и название, то ..
{
a = a + 1;
if (OrderTakeProfit() != StrToDouble(sTP) || OrderStopLoss() != StrToDouble(sSL))
{
OrderModify(OrderTicket(),OrderOpenPrice(),StrToDouble(sSL),StrToDouble(sTP),0,0);
}
break;                                                               // Функция прерывается
}
}
if (a == 0)                                                          // Если не найденно ордера с этим тикетом в коменнтариях, то
{
if (Use_multiply == true)                                            // Как выбирвется объем?
vol = Lot;                                                           // Фиксированый лот
else
vol = StrToDouble(svol) * Multiply;                                  // Коэффициент лота

if (StrToInteger(stype) == 0 || StrToInteger(stype) == 1)            // Какой тип сделки
{
double A,B;
A = (MarketInfo(Prefix + ssym + Suffix,MODE_ASK) - StrToDouble(sopen))* 100000;
B = (StrToDouble(sopen) - MarketInfo(Prefix + ssym + Suffix,MODE_BID)) * 100000;
if (B > slip + MarketInfo(Prefix + ssym + Suffix,MODE_SPREAD) ||                 // Перенос на следующую строку
    A > slip + MarketInfo(Prefix + ssym + Suffix,MODE_SPREAD))                   // Есть ли проскальзование
{
if(StrToInteger(stype) == 0)                                                                                                             
t = "Buy";
else
t = "Sell";
Alert ("Разница в ценах сервера. Ордер ", t," ", ssym," ", Name,"_",stiket," объемом ", NormalizeDouble(vol,2), " лота не открыт ");
}
else
{
if(StrToInteger(stype) == 0)                                         // Если покупка, то цена будет Ask                                                                     
price = MarketInfo(Prefix + ssym + Suffix,MODE_ASK);          

if(StrToInteger(stype) == 1)                                         // Если продажа, то цена будет Bid
price = MarketInfo(Prefix + ssym + Suffix,MODE_BID);

OrderSend(Prefix + ssym + Suffix,StrToInteger(stype),NormalizeDouble(vol,2),price,20,StrToDouble(sSL),StrToDouble(sTP),Name + "_" + stiket,0,0,0);     // Открытие ордера 
}
}
else
{
price = StrToDouble(sopen);                                          // Если отложенный ордер, то цена как у сервера

OrderSend(Prefix + ssym + Suffix,StrToInteger(stype),NormalizeDouble(vol,2),price,20,StrToDouble(sSL),StrToDouble(sTP),Name + "_" + stiket,0,0,0);     // Открытие ордера 
}
}         
   }
FileClose(handle);   
  
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

string    ssym;




total = OrdersTotal();

while (total >0)                                                    // Проверить все ордера
{
a = 0;
total = total - 1;
OrderSelect(total,SELECT_BY_POS);
if (StringFind(OrderComment(),Name,0)>=0)                           // Если в ордере есть название файла, то берем его в работу
{
handle = FileOpen(Name+"-3",FILE_COMMON|FILE_CSV|FILE_READ);
   while (FileIsEnding(handle) == false)
   {
   
          ssym =     FileReadString (handle);                        // Выгружаем символ
string    sopen =    FileReadString (handle),                        // Выгружаем цену открытия   
          sTP =      FileReadString (handle),                        // Выгружаем ТП
          sSL =      FileReadString (handle),                        // Выгружаем СЛ
          svol =     FileReadString (handle),                        // Выгружаем объем
          stiket =   FileReadString (handle),                        // Выгружаем номер тикета
          stype =    FileReadString (handle);                        // Выгружаем тип сделки
          
    if (StringFind(OrderComment(),stiket,0) >=0)                     // Если такой номер есть                 
    {    
    a =  1;
    break;
    }
          
}
FileClose(handle);
if ( a == 0)                                                         // Если такого ордера нет, то закрываем его
{
if (OrderType()!= 0 && OrderType()!= 1)
OrderDelete (OrderTicket(),0);                                       // Удаляем, если отложенный ордер
else
{
if (OrderType()== 0)
OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),20,0);                      // Закрываем по Биду покупки
if (OrderType()== 1)
OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),20,0);                      //Закрываем по Аску продажи
}
}
} 
}
}
else
time=true;
  
  
 
  }
//+------------------------------------------------------------------+

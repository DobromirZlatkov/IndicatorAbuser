//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Enums.mq4"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MACandleCloseInDirection : public ISignalIndicator
  {
private:
   ENUM_MA_METHOD     ma_type;
   ENUM_APPLIED_PRICE ma_applied_price;
   int                ma_period;
   int                ma_shift;
   int                m_shift;
public:
                     MACandleCloseInDirection() {};
                     MACandleCloseInDirection(ENUM_MA_METHOD type, ENUM_APPLIED_PRICE applied_price, int period, int shift, int back_shift)
     {
      ma_type = type;
      ma_applied_price = applied_price;
      ma_period = period;
      ma_shift = shift;
      m_shift = back_shift;
     }

   double            GetValue(double shift);
   SIGNAL_TYPE       GetSignal(double shift);
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MACandleCloseInDirection::GetValue(double shift)
  {
   double val = iMA(Symbol(), Period(), this.ma_period, this.ma_shift, this.ma_type, this.ma_applied_price, shift);
   return NormalizeDouble(val, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE MACandleCloseInDirection::GetSignal(double shift)
  {
   double close_price = iClose(Symbol(), Period(), 1 + shift);
   double open_price = iOpen(Symbol(), Period(), 1 + shift);
   double base_line = this.GetValue(shift);

   if(close_price > base_line && open_price < base_line)
     {
     // TODO if all candles to now are above and price is in atr
      for(int i=0;i<shift;i++)
        {
         double close = iClose(Symbol(), Period(), 1 + i);
         double currBase = this.GetValue(i);
         if(close < currBase)
           {
            return NO_SIGNAL;
           }
        }
      return BUY;
     }

   if(close_price < base_line && open_price > base_line)
     {
       for(int i=0;i<shift;i++)
        {
         double close = iClose(Symbol(), Period(), 1 + i);
         double currBase = this.GetValue(i);
         if(close > currBase)
           {
            return NO_SIGNAL;
           }
        }
      return SELL;
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+

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

   double            GetValue();
   SIGNAL_TYPE       GetSignal();
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MACandleCloseInDirection::GetValue(void)
  {
   double val = iMA(Symbol(), Period(), this.ma_period, this.ma_shift, this.ma_type, this.ma_applied_price, this.m_shift);
   return NormalizeDouble(val, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE MACandleCloseInDirection::GetSignal(void)
  {
   double close_price = iClose(Symbol(), Period(), 1);
   double open_price = iOpen(Symbol(), Period(), 1);
   double base_line = this.GetValue();

   if(close_price > base_line && open_price < base_line)
     {
      return BUY;
     }

   if(close_price < base_line && open_price > base_line)
     {
      return SELL;
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Enums.mq4"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MACrossExit : public ISignalIndicator
  {
private:
   ENUM_MA_METHOD     ma_type;
   ENUM_APPLIED_PRICE ma_applied_price;
   int                ma_period;
   int                ma_shift;
   int                m_shift;
public:
                     MACrossExit() {};
                     MACrossExit(ENUM_MA_METHOD type, ENUM_APPLIED_PRICE applied_price, int period, int shift, int back_shift)
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
double MACrossExit::GetValue(double shift)
  {
   double val = iMA(Symbol(), Period(), this.ma_period, this.ma_shift, this.ma_type, this.ma_applied_price, this.m_shift);
   return NormalizeDouble(val, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE MACrossExit::GetSignal(double shift)
  {
   double close_price = NormalizeDouble(iClose(Symbol(), Period(), 1), 3);
   double open_price = NormalizeDouble(iOpen(Symbol(), Period(), 1), 3);
   double base_line = this.GetValue(shift);
   
   if(close_price > base_line && open_price < base_line)
     {
      return SELL;
     }

   if(close_price < base_line && open_price > base_line)
     {
      return BUY;
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+

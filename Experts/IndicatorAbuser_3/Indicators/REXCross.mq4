//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Enums.mq4"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class REXCross : public ISignalIndicator
  {
private:
   int                smoothing_length;
   int                smoothing_method;
   int                signal_length;
   int                signal_method;
public:
                     REXCross() {};
                     REXCross(int input_smoothing_lenght, int input_smoothing_method, int input_signal_length, int input_signal_method)
     {
      smoothing_length = input_smoothing_lenght;
      smoothing_method = input_smoothing_method;
      signal_length = input_signal_length;
      signal_method = input_signal_method;
     }

   double            GetValue(double shift);
   SIGNAL_TYPE       GetSignal(double shift);
  };
//+------------------------------------------------------------------+

double REXCross::GetValue(double shift)
  {
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SIGNAL_TYPE REXCross::GetSignal(double shift)
  {
   double green = iCustom(Symbol(), Period(), "Rex", smoothing_length, smoothing_method, signal_length, signal_method, 0, 0);
   double red = iCustom(Symbol(), Period(), "Rex", smoothing_length, smoothing_method, signal_length, signal_method, 1, 0);
   double green1 = iCustom(Symbol(), Period(), "Rex", smoothing_length, smoothing_method, signal_length, signal_method, 0, 1);
   double red1 = iCustom(Symbol(), Period(), "Rex", smoothing_length, smoothing_method, signal_length, signal_method, 1, 1);

   double result = NO_SIGNAL;

   if(OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES))
     {
      string dateToKnow = TimeToStr(OrderOpenTime(), TIME_DATE);
      string currDate = TimeToStr(TimeCurrent(), TIME_DATE);
      if(dateToKnow == currDate)
        {
         return result;
        }
     }

   if(OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES))
     {
      if(OrderType() == OP_BUY)
        {
         if(green < red && green1 > red1)
           {
            result = BUY;
           }
        }

      if(OrderType() == OP_SELL)
        {
         if(green > red && green1 < red1)
           {
            result = SELL;
           }
        }
     }

   return result;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

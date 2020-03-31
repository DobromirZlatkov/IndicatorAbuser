//+------------------------------------------------------------------+
//|                                                 Indicator Abuser |
//|                                  Copyright 2020, Tobi-away Corp. |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Strategies/IStrategy.mq4"
#include "Strategies/ApplyDirectlyStrategy.mq4"

enum STRATEGY_TYPES
  {
   APPLY_DIRECTLY_STRATEGY = 0
  };

enum BASE_LINE_SIGANAL_TYPES
  {
   MA_CANDLE_CLOSE_IN_DIRECTION = 0
  };

enum EXIT_SIGNAL_TYPES
  {
   REX_CROSS = 0,
   BASE_LINE_CROSS = 1
  };

enum CONFIRMATION_TYPES
  {
   RSI_CONFIRM = 0,
   CMF_CONFIRM = 1
  };
  
enum EXTRA_ORDER_LOGICS
  {
   PARTIAL_CLOSE_ON_PIPS = 0
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StrategyBuilder
  {
private:
   STRATEGY_TYPES          m_strategy;
   BASE_LINE_SIGANAL_TYPES m_base_line_signal;
   ENUM_MA_METHOD    m_base_line_types;
   ENUM_APPLIED_PRICE m_base_line_applied_price;
   int               m_base_line_period;
   int               m_base_line_shif;

   EXIT_SIGNAL_TYPES exit_signal;
   int                smoothing_length;
   int                smoothing_method;
   int                signal_length;
   int                signal_method;

   CONFIRMATION_TYPES confirm_signal_1;
   ENUM_APPLIED_PRICE rsi_confirm_price;
   int                rsi_confirm_period;
   
   CONFIRMATION_TYPES confirm_signal_2;
   int                cmf_confirm_period;

public:
                     StrategyBuilder() {};
   //--- Default constructor
                     StrategyBuilder(
      STRATEGY_TYPES strategy,
      BASE_LINE_SIGANAL_TYPES base_line_signal,
      ENUM_MA_METHOD base_line_types,
      ENUM_APPLIED_PRICE base_line_applied_price,
      int base_line_period,
      int base_line_shift,

      EXIT_SIGNAL_TYPES exit_signal,
      int                smoothing_length,
      int                smoothing_method,
      int                signal_length,
      int                signal_method,

      CONFIRMATION_TYPES confirm_signal_1,
      ENUM_APPLIED_PRICE rsi_confirm_price,
      int                rsi_confirm_period,
      
      CONFIRMATION_TYPES confirm_signal_2,
      int                cmf_confirm_period

   )
     {
      this.m_strategy = strategy;
      this.m_base_line_signal = base_line_signal;
      this.m_base_line_types = base_line_types;
      this.m_base_line_applied_price = base_line_applied_price;
      this.m_base_line_period = base_line_period;
      this.m_base_line_shif = base_line_shift;

      this.exit_signal = exit_signal;
      this.smoothing_length = smoothing_length;
      this.smoothing_method = smoothing_method;
      this.signal_length = signal_length;
      this.signal_method = signal_method;

      this.confirm_signal_1 = confirm_signal_1;
      this.rsi_confirm_price = rsi_confirm_price;
      this.rsi_confirm_period = rsi_confirm_period;
      
      this.confirm_signal_2 = confirm_signal_2;
      this.cmf_confirm_period = cmf_confirm_period;
     }

   IStrategy*        Build();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IStrategy* StrategyBuilder::Build()
  {
   ISignalIndicator* base_line;

   if(this.m_base_line_signal == MA_CANDLE_CLOSE_IN_DIRECTION)
     {
      base_line = new MACandleCloseInDirection(m_base_line_types, m_base_line_applied_price, m_base_line_period, m_base_line_shif, 1);
     }
   else
     {
      Print("StrategyBuilder MA_CANDLE_CLOSE_IN_DIRECTION is invalid");
     }


   ISignalIndicator* exit_indicator;

   if(this.exit_signal == REX_CROSS)
     {
      exit_indicator = new REXCross(this.smoothing_length, this.smoothing_method, this.signal_length, this.signal_method);
     }
   else if(this.exit_signal == BASE_LINE_CROSS)
     {
      exit_indicator = new MACrossExit(m_base_line_types, m_base_line_applied_price, m_base_line_period, m_base_line_shif, 1);
     }
   else
     {
      Print("StrategyBuilder EXIT_SIGNAL_TYPES is invalid");
     }

   ISignalIndicator* confirm_indicator_1;

   if(this.confirm_signal_1 == RSI_CONFIRM)
     {
      confirm_indicator_1 = new RSIConfirm(rsi_confirm_price, rsi_confirm_period);
     }
   else
     {
      Print("StrategyBuilder CONFIRMATION_TYPES is invalid");
     }
     
   ISignalIndicator* confirm_indicator_23;

   if(this.confirm_signal_2 == RSI_CONFIRM)
     {
      confirm_indicator_23 = new RSIConfirm(rsi_confirm_price, rsi_confirm_period);
     }
   else if(this.confirm_signal_2 == CMF_CONFIRM)
     {
      confirm_indicator_23 = new CMFConfirm(cmf_confirm_period);
     }
   else
     {
      Print("StrategyBuilder CONFIRMATION_2_TYPES is invalid");
     }

   if(this.m_strategy == APPLY_DIRECTLY_STRATEGY)
     {
      return new ApplyDirectlyStrategy(base_line, exit_indicator, confirm_indicator_1, confirm_indicator_23);
     }
   else
     {
      Print("StrategyBuilder APPLY_DIRECTLY_STRATEGY is invalid");
     }

   return NULL;
  }
//+------------------------------------------------------------------+

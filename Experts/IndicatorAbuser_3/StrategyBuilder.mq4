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
   BASE_LINE_CROSS = 1,
   NONE_NDICATOR = 2
  };

enum CONFIRMATION_TYPES
  {
   RSI_CONFIRM = 0,
   CMF_CONFIRM = 1,
   TRADING_HOURS_CONFIRM = 2
  };
  
enum EXTRA_ORDER_LOGICS
  {
   NONE = 0,
   PARTIAL_CLOSE_ON_PIPS = 1,
   ATR_STOP_LOSS = 2,
   ADX_EXIT = 3,
   EXIT_ON_ALL_CONFIRM = 4
  };
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
   double             cmf_up;
   double             cmf_down;
   
   CONFIRMATION_TYPES confirm_signal_3;
   int                dont_trade_after;
   int                dont_trade_before;
   
   EXTRA_ORDER_LOGICS extra_order_logic;
   double             extra_order_logic_price_diff;
   double             extra_order_logic_lot_to_close;
   
   EXTRA_ORDER_LOGICS extra_order_logic_2;
   double             atr_stop_loss_period;
   double             atr_stop_loss_emplifier;
   
   EXTRA_ORDER_LOGICS extra_order_logic_3;
   double adx_close_above;
   double adx_top_above;
   
   EXTRA_ORDER_LOGICS extra_order_logic_4;

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
      int                cmf_confirm_period,
      double             cmf_up_input,
      double             cmf_down_input,
      
      CONFIRMATION_TYPES confirm_signal_3_input,
      int                dont_trade_after_input,
      int                dont_trade_before_input,
      
      EXTRA_ORDER_LOGICS extra_order_logic,
      double             extra_order_logic_price_diff,
      double             extra_order_logic_lot_to_close,
      
      EXTRA_ORDER_LOGICS extraOrderLogic_2,
      double             atrStopLossPeriod,
      double             atrStopLossEmplifier,
      
      EXTRA_ORDER_LOGICS extra_order_logic_3_input,
      double adx_close_above_input,
      double adx_top_above_input,
      
      EXTRA_ORDER_LOGICS extra_order_logic_4_input

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
      this.cmf_up = cmf_up_input;
      this.cmf_down = cmf_down_input;
      
      this.confirm_signal_3 = confirm_signal_3_input;
      this.dont_trade_after = dont_trade_after_input;
      this.dont_trade_before = dont_trade_before_input;
      
      this.extra_order_logic = extra_order_logic;
      this.extra_order_logic_price_diff = extra_order_logic_price_diff;
      this.extra_order_logic_lot_to_close = extra_order_logic_lot_to_close;
      
      this.extra_order_logic_2 = extraOrderLogic_2;
      this.atr_stop_loss_period = atrStopLossPeriod;
      this.atr_stop_loss_emplifier = atrStopLossEmplifier;
      
      this.extra_order_logic_3 = extra_order_logic_3_input;
      this.adx_close_above = adx_close_above_input;
      this.adx_top_above = adx_top_above_input;
      
      this.extra_order_logic_4 = extra_order_logic_4_input;
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
   else if(this.exit_signal == NONE_NDICATOR)
    {
      exit_indicator = new NoneIndicator();
    }
   else
     {
      Print("StrategyBuilder EXIT_SIGNAL_TYPES is invalid");
     }

   ISignalIndicator* confirm_indicators[2];

   if(this.confirm_signal_1 == RSI_CONFIRM)
     {
      confirm_indicators[0] = new RSIConfirm(rsi_confirm_price, rsi_confirm_period);
     }
   else if(this.confirm_signal_1 == CMF_CONFIRM)
     {
      confirm_indicators[0] = new CMFConfirm(cmf_confirm_period, cmf_up, cmf_down);
     }  
   else
     {
      Print("StrategyBuilder CONFIRMATION_TYPES is invalid");
     }
     

   if(this.confirm_signal_2 == RSI_CONFIRM)
     {
      confirm_indicators[1] = new RSIConfirm(rsi_confirm_price, rsi_confirm_period);
     }
   else if(this.confirm_signal_2 == CMF_CONFIRM)
     {
      confirm_indicators[1] = new CMFConfirm(cmf_confirm_period, cmf_up, cmf_down);
     }
   else
     {
      Print("StrategyBuilder CONFIRMATION_2_TYPES is invalid");
     }
     
   IOrderLogic* order_logics[4];
   
   if(this.extra_order_logic == NONE)
     {
      order_logics[0] = new None();
     }  
   else if(this.extra_order_logic == PARTIAL_CLOSE_ON_PIPS)
     {
      order_logics[0] = new PartialCloseOnPips(this.extra_order_logic_lot_to_close, this.extra_order_logic_price_diff);
     } 
   else
     {
      Print("StrategyBuilder EXTRA_ORDER_LOGICS is invalid");
     }
     
    if(this.extra_order_logic_2 == NONE)
     {
      order_logics[1] = new None();
     }
   else if(this.extra_order_logic_2 == ATR_STOP_LOSS)
     {
      order_logics[1] = new ATRStopLoss(this.atr_stop_loss_period, this.atr_stop_loss_emplifier);
     }  
   else
     {
      Print("StrategyBuilder extra_order_logic_2 is invalid");
     }  
     
   if(this.extra_order_logic_3 == NONE)
     {
      order_logics[2] = new None();
     }
   else if(this.extra_order_logic_3 == ADX_EXIT)
     {
      order_logics[2] = new ADXClose(this.adx_close_above, this.adx_top_above);
     }  
   else
     {
      Print("StrategyBuilder extra_order_logic_3 is invalid");
     }
     
   if(this.extra_order_logic_4 == NONE)
     {
      order_logics[3] = new None();
     }
   else if(this.extra_order_logic_4 == EXIT_ON_ALL_CONFIRM)
     {
      ISignalIndicator* exit_confirm_indicators[3];
      exit_confirm_indicators[0] = confirm_indicators[0];
      exit_confirm_indicators[1] = confirm_indicators[1];
      exit_confirm_indicators[2] = new MACandleCloseInDirection(m_base_line_types, m_base_line_applied_price, m_base_line_period, m_base_line_shif, 1);
      order_logics[3] = new ExitOnAllIndicatorsConfirm(exit_confirm_indicators); //new ADXClose(this.adx_close_above, this.adx_top_above);
     }  
   else
     {
      Print("StrategyBuilder extra_order_logic_4 is invalid");
     }    

   if(this.m_strategy == APPLY_DIRECTLY_STRATEGY)
     {
      return new ApplyDirectlyStrategy(base_line, exit_indicator, confirm_indicators, order_logics, dont_trade_after, dont_trade_before);
     }
   else
     {
      Print("StrategyBuilder APPLY_DIRECTLY_STRATEGY is invalid");
     }

   return NULL;
  }
//+------------------------------------------------------------------+

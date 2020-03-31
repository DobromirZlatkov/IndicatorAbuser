//+------------------------------------------------------------------+
//|                                             ElliottWaveLabel.mqh |
//|                               Copyright 2011, 2014 TradertoolsFX |
//|                                    http://www.tradertools-fx.com |
//|                                                                  |
//| Copyright (c) 2011, 2014 TradertoolsFX                           |
//|                                                                  |
//| Permission is hereby granted, free of charge, to any person      |
//| obtaining a copy of this software and associated documentation   |
//| files (the "Software"), to deal in the Software without          |
//| restriction, including without limitation the rights             |
//| to use, copy, modify, merge, publish, distribute, sublicense,    |
//| and/or sell copies of the Software, and to permit persons        |
//| to whom the Software is furnished to do so,                      |
//| subject to the following conditions:                             |
//|                                                                  |
//| The above copyright notice and this permission notice shall be   |
//| included in all copies or substantial portions of the Software.  |
//|                                                                  |
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  |
//| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE             |
//| WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR          |
//| PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR    |
//| COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      |
//| LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,  |
//| ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR       |
//| THE USE OR OTHER DEALINGS IN THE SOFTWARE.                       |
//+------------------------------------------------------------------+

// Label modes
#define NUMERIC  0
#define LETTER   1
#define ROMAN    2
//+------------------------------------------------------------------+
//| Class to draw and track elliott wave label chart objects         |
//+------------------------------------------------------------------+
class ElliottWaveLabel
  {
private:
   int               m_mode;
   int               m_num_waves;
   int               m_fn_size;
   string            m_fn_family;
   color             m_color;
   string            m_prefix;

   string            wave_label(int idx);
   string            wave_label_name(int cycle,int idx);
   string            index_to_alpha(int idx);
   string            int_to_roman(int n);
public:
                     ElliottWaveLabel(int mode,
                                                        int num_waves,
                                                        int fn_size,
                                                        string fn_family,
                                                        color color_,
                                                        string prefix);
   void              draw(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
ElliottWaveLabel::ElliottWaveLabel(int mode,
                                   int num_waves,
                                   int fn_size,
                                   string fn_family,
                                   color color_,
                                   string prefix)
  {
   m_mode=mode;
   m_num_waves=num_waves;
   m_fn_size=fn_size;
   m_fn_family=fn_family;
   m_color=color_;
   m_prefix=prefix;
  }
//+------------------------------------------------------------------+
//| Draw a label on the chart for the current wave                   |
//+------------------------------------------------------------------+
void ElliottWaveLabel::draw(void)
  {
   int cycle=0,idx=0;
   datetime time;
   double price;
   string name;

/* Loop through wave label objects to find the current name and wave index.
    * Once name is not found, the end has been reached and the name is the
    * new label name. */
   while(ObjectFind(name=wave_label_name(cycle,idx))>=0)
     {
      if(idx==(m_num_waves-1))
        { // Is this the end of the cycle?
         cycle++;
         idx=0; // Reset wave index
           } else {
         idx++;
        }
     }

// Set the drop coordinates
   time=WindowTimeOnDropped();
   price=WindowPriceOnDropped();

   ObjectCreate(name,OBJ_TEXT,0,time,price);
   ObjectSetText(name,wave_label(idx),m_fn_size,m_fn_family,m_color);
  }
//+------------------------------------------------------------------+
//| Return the wave label string given the wave index idx            |
//+------------------------------------------------------------------+
string ElliottWaveLabel::wave_label(int idx)
  {
   switch(m_mode)
     {
      case NUMERIC:
         return IntegerToString(idx + 1);
      case LETTER:
         return index_to_alpha(idx);
      case ROMAN:
         return int_to_roman(idx + 1);
      default:
         return "Invalid mode for wave label";
     }
  }
//+------------------------------------------------------------------+
//| Return the wave label's internal object name                     |
//| given the cycle and wave index idx.                              |
//+------------------------------------------------------------------+
string ElliottWaveLabel::wave_label_name(int cycle,int idx)
  {
   return StringConcatenate(m_prefix, cycle, "_", idx);
  }
//+------------------------------------------------------------------+
//| Return the capital letter(s) corresponding to idx,               |
//| where 0 corresponds to A, 1 to B, and so on.                     |
//| If idx exceeds 25 (Z), the return value will be appended         |
//| such that 26 is AA, 27 is BB, and so on.                         |
//+------------------------------------------------------------------+
string ElliottWaveLabel::index_to_alpha(int idx)
  {
   string res = "";
   int repeat = 1;
   int c='A'+idx;

// Just in case NUM_WAVES > 26
   while(c>'Z')
     {
      c-=26;
      repeat++;
     }

   while(repeat-->0)
     {
      res+=CharToStr((char)c);
     }

   return res;
  }
//+------------------------------------------------------------------+
//| Return the roman numeral string representation                   |
//| given a positive integer n.                                      |
//+------------------------------------------------------------------+
string ElliottWaveLabel::int_to_roman(int n)
  {
   int digits[]={ 1,4,5,9,10,40,50,90,100,400,500,900,1000 };
   string romn[]=
     {
      "I","IV","V","IX","X","XL",
      "L","XC","C","CD","D","CM","M"
     };

   string roman="";
   int sz= MathMin(ArraySize(romn),ArraySize(digits));
   int i = sz-1;

   while(i>=0)
     {
      if(n<digits[i])
        {
         i--;
           } else {
         n-=digits[i];
         roman=StringConcatenate(roman,romn[i]);
        }
     }

   return roman;
  }
//+------------------------------------------------------------------+

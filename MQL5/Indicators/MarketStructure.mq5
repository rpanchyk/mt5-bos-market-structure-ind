//+------------------------------------------------------------------+
//|                                              MarketStructure.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024, rpanchyk"
#property link        "https://github.com/rpanchyk"
#property version     "1.00"
#property description "Indicator shows market structure"

#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2

// types
enum ENUM_ARROW_SIZE
  {
   SMALL_ARROW_SIZE = 1, // Small
   REGULAR_ARROW_SIZE = 2, // Regular
   BIG_ARROW_SIZE = 3, // Big
   HUGE_ARROW_SIZE = 4 // Huge
  };

// buffers
double ExtHighPriceBuffer[]; // higher price
double ExtLowPriceBuffer[]; // lower price

// config
input group "Section :: Main";
int InpPeriod = 5; // Period

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = SMALL_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
input color InpLowerLowColor = clrRed; // Lower low color

input group "Section :: Dev";
input bool InpDebugEnabled = false; // Endble debug (verbose logging)

// runtime
int highIdx = 0;
int lowIdx = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator initialization started");
     }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArrayInitialize(ExtHighPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(0, ExtHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "Higher High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

   ArrayInitialize(ExtLowPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(1, ExtLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Lower Low");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, InpArrowShift);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);

   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator initialization finished");
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator deinitialization started");
     }

   ArrayFill(ExtHighPriceBuffer, 0, ArraySize(ExtHighPriceBuffer), EMPTY_VALUE);
   ArrayFree(ExtHighPriceBuffer);

   ArrayFill(ExtLowPriceBuffer, 0, ArraySize(ExtLowPriceBuffer), EMPTY_VALUE);
   ArrayFree(ExtLowPriceBuffer);

   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator deinitialization finished");
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }

   int limit = rates_total - (prev_calculated == 0 ? 1 : prev_calculated);
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   for(int i = (prev_calculated == 0 ? 1 : prev_calculated); i < rates_total; i++)
     {
      if(high[i] > high[highIdx])
        {
         SetHigh(time, high, low, i);
        }
      if(low[i] < low[lowIdx])
        {
         SetLow(time, high, low, i);
        }
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetHigh(const datetime &time[], const double &high[], const double &low[], int i)
  {
   if(i - highIdx >= InpPeriod)
     {
      lowIdx = highIdx;
      for(int j = highIdx + 1; j <= i; j++)
        {
         if(low[j] < low[lowIdx])
           {
            lowIdx = j;
           }
        }
      ExtLowPriceBuffer[lowIdx] = low[lowIdx];
      if(InpDebugEnabled)
        {
         Print("Calculated Low on ", lowIdx, " bar at ", time[lowIdx], " in range: ", highIdx, "-", i);
        }
     }
   else
     {
      ExtHighPriceBuffer[highIdx] = EMPTY_VALUE;
     }

   highIdx = i;
   ExtHighPriceBuffer[highIdx] = high[highIdx];
   if(InpDebugEnabled)
     {
      Print("High on ", highIdx, " bar at ", time[highIdx]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLow(const datetime &time[], const double &high[], const double &low[], int i)
  {
   if(i - lowIdx >= InpPeriod)
     {
      highIdx = lowIdx;
      for(int j = lowIdx + 1; j <= i; j++)
        {
         if(high[j] > high[highIdx])
           {
            highIdx = j;
           }
        }
      ExtHighPriceBuffer[highIdx] = high[highIdx];
      if(InpDebugEnabled)
        {
         Print("Calculated High on ", highIdx, " bar at ", time[highIdx], " in range: ", lowIdx, "-", i);
        }
     }
   else
     {
      ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
     }

   lowIdx = i;
   ExtLowPriceBuffer[lowIdx] = low[lowIdx];
   if(InpDebugEnabled)
     {
      Print("Low on ", lowIdx, " bar at ", time[lowIdx]);
     }
  }
//+------------------------------------------------------------------+

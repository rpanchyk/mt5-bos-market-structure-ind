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
#property indicator_plots 0

// buffers
//..

// config
input group "Section :: Main";
//...

input group "Section :: Dev";
input bool InpDebugEnabled = true; // Endble debug (verbose logging)

// constants
//...

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator initialization started");
     }

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

   int limit = rates_total - (prev_calculated < 1 ? 1 : prev_calculated);
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   for(int i = limit - 1; i > 0; i--) // Go from left to right bars
     {
      Print(i);
     }

   return rates_total;
  }
//+------------------------------------------------------------------+

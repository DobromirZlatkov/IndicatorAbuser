

#property copyright "(c) Acuity Trading."
#property link "www.acuitytrading.com"

#import "nquotes/nquoteslib.ex4"
	int nquotes_setup(string className, string assemblyName);
	int nquotes_init();
	int nquotes_start();
	int nquotes_deinit();
	double nquotes_on_tester();
	int nquotes_on_timer();
	int nquotes_on_chart_event(int id, long lparam, double dparam, string sparam);

	int nquotes_set_property_bool(string name, bool value);
	int nquotes_set_property_int(string name, int value);
	int nquotes_set_property_double(string name, double value);
	int nquotes_set_property_datetime(string name, datetime value);
	int nquotes_set_property_color(string name, color value);
	int nquotes_set_property_string(string name, string value);
	int nquotes_set_property_adouble(string name, double& value[], int count=WHOLE_ARRAY, int start=0);

	bool nquotes_get_property_bool(string name);
	int nquotes_get_property_int(string name);
	double nquotes_get_property_double(string name);
	datetime nquotes_get_property_datetime(string name);
	color nquotes_get_property_color(string name);
	string nquotes_get_property_string(string name);
	int nquotes_get_property_array_size(string name);
	int nquotes_get_property_adouble(string name, double& value[]);
#import

#import "NPipeMT4.dll" 
    void StartServer(string name);
    string GetData();
    void ClearData();
    string SetResponse(string response);
    string GetResponse();
    void ClosePipeServer();
    void RestartServer(string name);
#import 

input double EnableLogging = 0;

int init()
{
   GlobalVariableSet("EnableLogging", EnableLogging);
   
	nquotes_setup("ExpertAdvisor.ExpertAdvisor", "ExpertAdvisor");
	
   int ini = nquotes_init();
  
   if(ini > -1)
   {
      StartServer(ChartID());
      Print("Start Server");
      EventSetMillisecondTimer(40);
   }
   
	return (0);
}


void OnTimer()
{
   string request = GetData();

   if(request != "")
   {
      string results[];
      long chartID = StringSubstr(request, 0, 19);
      string methodType = StringSubstr(request, 19, 30);
      string symbol = StringSubstr(request, 49, 450);
      
      ClearData();
      string answer = "";
      
      if (StringFind(methodType, "GetExistSymbol") > -1)
      {
         int leng01 = StringSplit(symbol, 11, results);     // 11 --> '\v'
         answer = "false";
         for(int i = 0; i < leng01; i++)
         {
            symbol = results[i];
            MarketInfo(symbol, MODE_BID);                
            int t = GetLastError();
            if(t != 4106)                                   // if symbol not found
            {    
               answer = "true";
               break;
            }
         }
         
         if(answer == "false")
         {
            SetResponse(answer);
            MessageBox("Not found symbol for " + results[0], results[0], MB_OK);
            return;
         }
         
         SetResponse(symbol + "\0");
      }
      else if (StringFind(methodType, "ChartSetSymbolPeriod") > -1)
      {
         int leng1 = StringSplit(symbol, 11, results);     // 11 --> '\v'
         answer = "false";
         for(int j = 0; j < leng1; j++)
         {
            symbol = results[j];
            MarketInfo(symbol, MODE_BID);                
            int e = GetLastError();
            if(e != 4106)                                   // if symbol not found
            {    
               answer = "true";
               break;
            }
         }
         
         if(answer == "false")
         {
            SetResponse(answer);
            MessageBox("Not found symbol for " + results[0], results[0], MB_OK);
            //SetResponse("false");
            return;
         }
         
         if(chartID && symbol)
         {
            if(symbol == Symbol())
            {
               SetResponse("false");
               return;
            }
         
            //GlobalVariableSet(ChartID() + "isRedrawChart", 1);
          
            SetResponse("true");
            //ChartSetSymbolPeriod(chartID, symbol, Period());
            ChartOpen(symbol, Period());
         }
         else
         {
            SetResponse("Invalid input data");
         }        
      }
      else if (StringFind(methodType, "CheckSymbolExist") > -1)
      {
         MarketInfo(symbol, MODE_BID);
         
         if(GetLastError() != 4106)       
            answer = "true";
         else
            answer = "false";
            
         SetResponse(answer);
      }
      else if (StringFind(methodType, "MessageBox") > -1)
      {
         int len = StringSplit(symbol, StringGetCharacter("0", 0), results);
         if(len > 0)
         {
            MessageBox(results[0], results[0], MB_OK);
            SetResponse("true");
         }
      }
      else if (StringFind(methodType, "GlobalVariableSet") > -1)
      {
         int leng2 = StringSplit(symbol, StringGetCharacter("0", 0), results);
         if(leng2 > 0)
         {
            GlobalVariableSet(ChartID() + results[0], chartID);
         }
         SetResponse("true");
      }
      else if (StringFind(methodType, "GlobalVariableGet") > -1)
      {
         int leng3 = StringSplit(symbol, StringGetCharacter("0", 0), results);
         if(leng3 > 0)
         {
            double test = GlobalVariableGet(ChartID() + results[0]);
            if(test > 0.1)
               SetResponse("true");
            else
               SetResponse("false");  
         }
         else
         {
            SetResponse("false");
         }
      }
      else if (StringFind(methodType, "CloseMA") > -1)
      {
         GlobalVariableSet(ChartID() + "isMarketAlerts", 0);
         GlobalVariableSet("isOpenMarketAlerts", 0);     
         SetResponse("true");
         ExpertRemove();
      }
   }  

}

int start()
{
  
   return (0);
}

int deinit()
{
   int ans = nquotes_deinit();
   if(ans > 0)
   {
      ClosePipeServer();
   }
	return (0);
}

double OnTester()
{
	return 0;
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
	//nquotes_on_chart_event(id, lparam, dparam, sparam);
}
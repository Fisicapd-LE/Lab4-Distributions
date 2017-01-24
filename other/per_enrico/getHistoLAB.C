//Digiitizer data from the LAB
#include <string>

struct slimport_data_t {
  ULong64_t	timetag;
  UInt_t		baseline;
  UShort_t	qshort;
  UShort_t	qlong;
  UShort_t	pur;
  UShort_t	samples[4096];
};

TH1F* getHistoFromTree(char *name_file, int numBins, double minX, double maxX, const char *channel) {
  // variables
  slimport_data_t indata;
  TFile *infile = new TFile(name_file);
  TTree *intree = (TTree*)infile->Get("acq_tree_0");
  string branchname = "acq_ch";
  branchname += channel;
  TBranch *inbranch = intree->GetBranch(branchname.c_str());
  inbranch->SetAddress(&indata.timetag);
  TH1F *h_spectrum = new TH1F("h_spectrum","Total spectrum",numBins,minX,maxX);
  // histogram filling
  for (int i=0; i<inbranch->GetEntries(); i++) {
    inbranch->GetEntry(i);
    h_spectrum->Fill(indata.qlong);
  }
  // return
  return h_spectrum;
}


TH1F* getHistoWithFilter(char *name_file, int numBins, double minX, double maxX, double lowThr0 = 0, double highThr0 = 999999, double lowThr1 = 0, double highThr1 = 999999)
{
  // variables
  slimport_data_t indata0;
  slimport_data_t indata1;
  TFile *infile = new TFile(name_file);
  TTree *intree = (TTree*)infile->Get("acq_tree_0");
  TBranch *inbranch0 = intree->GetBranch("acq_ch0");
  TBranch *inbranch1 = intree->GetBranch("acq_ch1");
  inbranch0->SetAddress(&indata0.timetag);
  inbranch1->SetAddress(&indata1.timetag);
  TH1F *h_spectrum0 = new TH1F("h_spectrum0","Total spectrum0",numBins,minX,maxX);
  TH1F *h_spectrum1 = new TH1F("h_spectrum1","Total spectrum1",numBins,minX,maxX);
  
  int k = 0;	//new index for cycles
  
  // histogram filling
  for (int i=0; i<inbranch0->GetEntries(); i++) {	//cycle over R1 data
    inbranch0->GetEntry(i);
    if (indata0.qlong>lowThr0 && indata0.qlong<highThr0)	//the single energy measurement is in the peak 
    {
      //cout << "DEBUG: timetag0 = " << indata1.timetag << endl;
      while(indata1.timetag < indata0.timetag - 500  ||  indata1.timetag > indata0.timetag +500)		//find the coincidence
      {
	if(k > inbranch1->GetEntries()) 
	{
	  cout << "Corresponding timetag not found!" << endl;
	  break; 
	}
	if(k < 100)
	{
	  //cout << "DEBUG: timetag at k = " << k << " is " << indata1.timetag << endl;
	}
	inbranch1->GetEntry(k);
	k++;
      }
      if(indata1.qlong>lowThr1 && indata1.qlong<highThr1)
      {
	cout << "Coincidence Found!" << endl;
        h_spectrum0->Fill(indata0.qlong);
        h_spectrum1->Fill(indata1.qlong);
      }
	
    }
  }
  // return
  return h_spectrum0;
} 

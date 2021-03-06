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
  
  Long64_t i = 0;
  Long64_t k = 0;	//new index for cycles
  Long64_t ksave;
  Long64_t imax = inbranch0->GetEntries();
  Long64_t kmax = inbranch1->GetEntries();
  bool trigger = 1;	//trigger == TRUE
  
  cout << "DEBUG: kmax = "<< kmax << " imax = " << imax << endl;
  inbranch1->GetEntry(k);
  
  // histogram filling
  for (i=0; i<imax; i++) {	//cycle over R1 data
    inbranch0->GetEntry(i);
    if (indata0.qlong>lowThr0 && indata0.qlong<highThr0)	//the single energy measurement is in the peak 
    {
      trigger = 1;
      //cout << "DEBUG: timetag0 = " << indata1.timetag << endl;
      while(indata1.timetag < indata0.timetag -100 && k < kmax)	//find the coincidence
      {
	inbranch1->GetEntry(k);
	k++;
      }
      if(indata1.timetag > (indata0.timetag + 100)) 
      {
	//cout << "DEBUG: timetag0 = " << indata0.timetag << " timetag1 = " << indata1.timetag << " k = " << k << endl;
	//cout << "DEBUG: condition = " << (indata1.timetag > indata0.timetag + 100) << endl;
	//cout << "DEBUG: indata0.timetag + 100 = " << indata0.timetag + 100 << endl;
	//cout << "DEBUG: distance " << indata0.timetag +100 - indata1.timetag << endl;
	cout << "Corresponding timetag not found!" << endl;
	trigger = 0;
	if(k!=0) k--;
	continue; 
      }
      if(indata1.qlong>lowThr1 && indata1.qlong<highThr1 && trigger && k <= kmax)
      {
	cout << "Coincidence Found!" << endl;
        h_spectrum0->Fill(indata0.qlong);
        h_spectrum1->Fill(indata1.qlong);
      }
      
      while((indata1.qlong<lowThr1 || indata1.qlong>highThr1) && k < kmax)
      {
	ksave = k;
	k++;
	inbranch1->GetEntry(k);
	if(indata1.timetag < indata0.timetag +100 && indata1.qlong>lowThr1 && indata1.qlong<highThr1)
	{
	  h_spectrum0->Fill(indata0.qlong);
	  h_spectrum1->Fill(indata1.qlong);
	  break;
	}
	if(indata1.timetag > indata0.timetag +100) 
	{
	  k = ksave;
	  break;
	}
      }
      
    }
  }
  // return
  return h_spectrum0;
} 

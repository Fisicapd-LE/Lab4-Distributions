#include <iostream>
#include <cmath>

double func_I(double theta);
double rad(double theta);
double deg(double theta);


double r = 4;
double R = 14.1; 
double G = atan(r/R);
double a = 0.12;
double b= 0.042;


int main()
{
  using namespace std;
  
  double theta[11] = {180, 170, 160, 150, 140, 130, 110, 100, 90, 170};
  double alphabar;
  for(int i =0; i < 11; i++)
  {
   alphabar = acos( -sqrt( (sqrt( a*a -4*b*(1-func_I(rad(theta[i])))) -a )/ (2*b)) );
   cout << i << " angle: " << deg(alphabar) << endl;
  }
 return 0; 
}

double func_I(double mu)
{
  double result;
  result = (1. / (2.*G))*((sin(mu+G)* cos(mu+G) * cos(mu+G) * cos(mu+G) - sin(mu-G)* cos(mu-G) * cos(mu-G) * cos(mu-G))*(b/4.) + ((3.*b / 4.) + a)*0.5*(sin(mu+G)*cos(mu+G)-sin(mu-G)*cos(mu-G))+
           (3.*b/4.+ a + 2.)*G);
  //std::cout << "I value = " << result << std::endl;
  return result;
}

double rad(double theta)
{
  return (theta*M_PI)/180.;
}

double deg(double theta)
{
  return (theta*180.)/M_PI;
}
/*********************************************
 * OPL 12.5 Model
 * Author: eyvindso
 * Creation Date: 2013-04-16 at 3:11:28 PM
 *********************************************/

 int no_Stands = ...;
 int no_Goals = ...;
 int max_no_Schedules = ...;
 int no_Inventories = ...;

 int no_scen_per_inv = ...;
 int no_periods=...;

 int no_Total_Inventories = 9*no_scen_per_inv;
 
 
 range Stands = 1..no_Stands;
 range Schedules = 1..max_no_Schedules;
 range Goals = 1..no_Goals;
 range Income_Goals = 1..6;
 range Inventories = 1..no_Inventories;
 range Scen_per_inv = 1..no_scen_per_inv;
 range Total_Inventories = 0..no_Total_Inventories;
 range periods = 1..no_periods;
 range periodsb = 2..no_periods;
 range data_sets = 1..no_periods;
  
 float iters[periods][periods] = ...;
 float data[Stands][Schedules][Total_Inventories][Goals] = ...;
 int scenarios[Stands][Schedules][periods][1..9][Scen_per_inv] = ...;
 int S[Stands][Schedules][periods][1..5] = ...;
 int test[1..6][1..2] = ...;
 int tested[1..6][1..2] = ...;
 
 float MAX_NPV[1..11] = ...;
 
 int INV_RAND[Stands][1..no_Inventories]= ...;
 
 float stand_area[Stands] = ...;
 float SCHED[Schedules] = ...; 
 
 float lambda[1..26] = ...;
 int lambdas = ...;
		
  /*int mySeed; execute
{ var now = 

new Date(); mySeed = Opl.srand(Math.round(now.getTime()/1000)); 
} */

dvar float+ NPV[Inventories][Scen_per_inv][1..2];
dvar float+ CUT[1..2][Inventories][Stands][Schedules];


dvar float Income_2[Inventories][Scen_per_inv][1..2][1..6];
		
float costs_inv = ...;
dvar float+ PV[Inventories][Scen_per_inv][1..2];	
dvar float+ CVAR_1[1..6];
dvar float+ Z_1[1..6];
dvar float+ CVAR_2[Inventories][1..6];
dvar float+ Z_2[Inventories][1..6];

float ALPHA[1..3] = ...;
int ALPHAs = ...;

dvar float+ Losses_p[Inventories][Scen_per_inv][1..2][1..6];
dvar float+ Losses_n[Inventories][Scen_per_inv][1..2][1..6];
float target = ...;
float interest[1..11] = ...;
int int_v = ...;

dvar float+ negZ[Inventories][Scen_per_inv][1..2][1..6];
dvar float+ posZ[Inventories][Scen_per_inv][1..2][1..6];
int v2[1..6][1..6] = [[0,0,0,0,0,0],[0,1,0,0,0,0],[0,0,1,0,0,0],[0,0,0,1,0,0],[0,0,0,0,1,0],[0,0,0,0,0,1]];
int v4[1..6][1..6] = [[0,0,0,0,0,0],[0,1,1,1,1,1],[0,0,1,1,1,1],[0,0,0,1,1,1],[0,0,0,0,1,1],[0,0,0,0,0,1]];

dvar float help;
dvar float help2[1..2];
dvar float NPVdata[1..6];
dvar float PVdata[1..6];
dvar float Incdata[1..6][1..6];
dvar float max_CVAR[1..2];
int it = ...;
int FOR_CVAR_1[1..6] = [7,2,3,4,5,6];
//dvar float income[Inventories][Scen_per_inv][1..6];



maximize 	
help2[1]*(1-v4[2][it])
	
+help2[2]*(v4[2][it])	


;
 			
subject to{


help2[1] ==sum(inv in Inventories, scen in Scen_per_inv)NPV[inv][scen][1]/(no_scen_per_inv*no_Inventories*MAX_NPV[int_v])- 
(lambda[lambdas])*sum(t in 1..6)CVAR_1[t]/target;
	help2[2] == sum(inv in Inventories, scen in Scen_per_inv)NPV[inv][scen][2]*(v4[2][it])/(no_scen_per_inv*no_Inventories*MAX_NPV[int_v])-(lambda[lambdas])*
	(sum(t in 1..(it-1))CVAR_1[t]/target+sum(inv in Inventories, t in it..6)CVAR_2[inv][t]/(no_Inventories*target));

	//NPV	
	
forall(inv in Inventories, scen in Scen_per_inv, g in 1..2)
NPV[inv][scen][g] == 
sum(t in 1..6)((Income_2[inv][scen][g][t])/((1+interest[int_v])^(t*5-2.5)))+
PV[inv][scen][g]/((1+interest[int_v])^(30));

// Income

forall(inv in Inventories, scen in Scen_per_inv, g in 1..2)
PV[inv][scen][g] == sum(j in Stands, k in Schedules)
(data[j][k][scenarios[j][k][test[it][g]][INV_RAND[j][inv]][scen]][21]*CUT[g][inv][j][k]);


forall(inv in Inventories, scen in Scen_per_inv, t in 1..6,g in 1..2)
Income_2[inv][scen][g][t] == sum(j in Stands, k in Schedules)
((data[j][k][scenarios[j][k][test[it][g]][INV_RAND[j][inv]][scen]][13+t]*CUT[g][inv][j][k]*v4[test[it][g]][t])
+((data[j][k][scenarios[j][k][1][INV_RAND[j][inv]][scen]][13+t]*CUT[1][inv][j][k])*(1-v4[test[it][g]][t])))-costs_inv*v2[test[it][g]][t];


//Losses
forall(inv in Inventories, scen in Scen_per_inv, t in 1..6,g in 1..2)
 target - Income_2[inv][scen][g][t] -Losses_p[inv][scen][g][t] + Losses_n[inv][scen][g][t] == 0;

//CVAR_1

forall(t in 1..(FOR_CVAR_1[it]-1))
	CVAR_1[t] == 
	(Z_1[t]+(1/((1-ALPHA[ALPHAs])*(no_scen_per_inv*no_Inventories)))*sum(inv in Inventories, scen in Scen_per_inv)(posZ[inv][scen][1][t]));

forall(inv in Inventories, scen in Scen_per_inv, t in 1..(FOR_CVAR_1[it]-1))
   	Losses_p[inv][scen][1][t]-Z_1[t]+(negZ[inv][scen][1][t] - posZ[inv][scen][1][t]) == 0;

//CVAR_2
forall(t in (FOR_CVAR_1[it])..6, inv in Inventories)
	CVAR_2[inv][t] == 
	(Z_2[inv][t]+(1/((1-ALPHA[ALPHAs])*(no_scen_per_inv)))*sum(scen in Scen_per_inv)(posZ[inv][scen][2][t])); 


forall(inv in Inventories, scen in Scen_per_inv, t in (FOR_CVAR_1[it]-1)..6)
   	Losses_p[inv][scen][2][t]-Z_2[inv][t]+(negZ[inv][scen][2][t] - posZ[inv][scen][2][t]) == 0;   	

//Inventory Constraint

forall(l in Inventories, j in Stands, g in 1..2,t in 1..6,tk in 1..5)
const_2:sum(k in Schedules)((CUT[g][l][j][k]-CUT[1][l][j][k])*S[j][k][t][tk])-sum(p in 1..t)(v2[test[it][g]][p])*100000000 <= 0; // check timing

forall(l in Inventories, j in Stands, g in 1..2,t in 1..6,tk in 1..5)
const_2a:sum(k in Schedules)((CUT[1][l][j][k]-CUT[g][l][j][k])*S[j][k][t][tk])-sum(p in 1..t)(v2[test[it][g]][p])*100000000 <= 0; // check timing

forall(j in Stands, l in Inventories,g in 1..2)
cut_constraint: sum(k in Schedules) CUT[g][l][j][k] == stand_area[j];

forall(g in 1..2)
NPVdata[g] == sum(inv in Inventories, scen in Scen_per_inv) NPV[inv][scen][g]/(no_scen_per_inv*no_Inventories);

forall(g in 1..2)
PVdata[g] == sum(inv in Inventories, scen in Scen_per_inv) PV[inv][scen][g]/(no_scen_per_inv*no_Inventories);

forall(g in 1..2,j in 1..6)
Incdata[g][j] == sum(inv in Inventories, scen in Scen_per_inv) Income_2[inv][scen][g][j]/(no_scen_per_inv*no_Inventories);

}


main {
  cplex.tilim = 1000;
  var status = 0;
  //thisOplModel.generate();	
  var Forest = thisOplModel;
  var data = Forest.dataElements;	
  var def = Forest.modelDefinition;

      
  Forest = new IloOplModel(def,cplex);
  //Forest.addDataSource(data);
  
  //Forest.generate();
   
 
  var iter = 6;
  var ints = 1;	
 	 
  //var basis = new IloOplCplexVectors();
  var ofile = new IloOplOutputFile("INV_55_1_again_new.txt");
  ofile.writeln("Iteration\tInterest\tG\tOBJ[1]\tOBJ[2]\tNPV1\tNPV2\tCVAR[1][1]\tCVAR[1][2]\tCVAR[1][3]\tCVAR[1][4]\tCVAR[1][5]\tCVAR[1][6]\tCVAR[2][1]\tCVAR[2][2]\tCVAR[2][3]\tCVAR[2][4]\tCVAR[2][5]\tCVAR[2][6]\tNPVdata[1]\tNPVdata[2]\tPVdata[1]\tPVdata[2]\tINC[1][1]\tINC[1][2]\tINC[1][3]\tINC[1][4]\tINC[1][5]\tINC[1][6]\tINC[2][1]\tINC[2][2]\tINC[2][3]\tINC[2][4]\tINC[2][5]\tINC[2][6]\ttime(ms)\trelativeGap\ttarget\tAlpha");

  for (var tg=55000	; tg >= 55000; tg=tg-5000) {
  for (var alp=1	; alp <= 1; alp++) {  
  for (var ints=5; ints <= 5; ints=ints+1) {
  for (var iter=1; iter <= 26	; iter=iter+1) {
  for (var g=1	; g <= 6; g++) {  	
  
  Forest = new IloOplModel(def,cplex);	
    
  data.lambdas = iter;
  data.int_v = ints;
  data.it = g;		
  data.target = tg;
  data.ALPHAs = alp;
  
  Forest.addDataSource(data);
  Forest.generate();
	 //  if ( !basis.setVectors(cplex) ) {
      //writeln("warm start ",basis.Nrows,"x",basis.Ncols," failed: ",basis.status);
   //} else {
      //writeln("warm start ",basis.Nrows,"x",basis.Ncols," succeeded ");
   //}
	
  var before = new Date();
  temp = before.getTime();
	
    
    if ( cplex.solve() ) {
    var after = new Date();
	writeln("solving time ~= ",after.getTime()-temp);    
    
     var curr = cplex.getObjValue();
     var best =cplex.getBestObjValue();
     var rest =curr/best;
     var relativeGap = (cplex.getObjValue()-cplex.getBestObjValue())/(cplex.getObjValue()+1e-10);

var NPV_1 = 0
var NPV_2 = 0
var CVAR_1_1 = 0;
var CVAR_1_2 = 0;
var CVAR_1_3 = 0;	
var CVAR_1_4 = 0;
var CVAR_1_5 = 0;
var CVAR_1_6 = 0;

var CVAR_2_1 = 0;
var CVAR_2_2 = 0;
var CVAR_2_3 = 0;	
var CVAR_2_4 = 0;
var CVAR_2_5 = 0;
var CVAR_2_6 = 0;

for (var c =1; c  <= Forest.no_Inventories; c++) {
	
CVAR_1_1 = CVAR_1_1 + Forest.CVAR_1[1]/Forest.no_Inventories
CVAR_1_2 = CVAR_1_2 + Forest.CVAR_1[2]/Forest.no_Inventories
CVAR_1_3 = CVAR_1_3 + Forest.CVAR_1[3]/Forest.no_Inventories
CVAR_1_4 = CVAR_1_4 + Forest.CVAR_1[4]/Forest.no_Inventories
CVAR_1_5 = CVAR_1_5 + Forest.CVAR_1[5]/Forest.no_Inventories
CVAR_1_6 = CVAR_1_6 + Forest.CVAR_1[6]/Forest.no_Inventories

CVAR_2_1 = CVAR_2_1 + Forest.CVAR_2[c][1]/Forest.no_Inventories
CVAR_2_2 = CVAR_2_2 + Forest.CVAR_2[c][2]/Forest.no_Inventories
CVAR_2_3 = CVAR_2_3 + Forest.CVAR_2[c][3]/Forest.no_Inventories
CVAR_2_4 = CVAR_2_4 + Forest.CVAR_2[c][4]/Forest.no_Inventories
CVAR_2_5 = CVAR_2_5 + Forest.CVAR_2[c][5]/Forest.no_Inventories
CVAR_2_6 = CVAR_2_6 + Forest.CVAR_2[c][6]/Forest.no_Inventories

for (var d =1; d  <= Forest.no_scen_per_inv; d++) {
NPV_1 = NPV_1 + Forest.NPV[c][d][1]/(Forest.no_Inventories*100)
 
NPV_2 = NPV_2 + Forest.NPV[c][d][2]/(Forest.no_Inventories*100)			
}
}
     

ofile.writeln(Forest.lambda[iter],"\t",ints,"\t",g,"\t",Forest.help2[1],"\t",Forest.help2[2],"\t",NPV_1,"\t",NPV_2,"\t",
CVAR_1_1,"\t",CVAR_1_2,"\t",CVAR_1_3,"\t",CVAR_1_4,"\t",CVAR_1_5,"\t",CVAR_1_6,"\t",
CVAR_2_1,"\t",CVAR_2_2,"\t",CVAR_2_3,"\t",CVAR_2_4,"\t",CVAR_2_5,"\t",CVAR_2_6
,"\t",Forest.NPVdata[1],"\t",Forest.NPVdata[2]
,"\t",Forest.PVdata[1],"\t",Forest.PVdata[2]
,"\t",Forest.Incdata[1][1],"\t",Forest.Incdata[1][2],"\t",Forest.Incdata[1][3],"\t",Forest.Incdata[1][4],"\t",Forest.Incdata[1][5],"\t",Forest.Incdata[1][6]
,"\t",Forest.Incdata[2][1],"\t",Forest.Incdata[2][2],"\t",Forest.Incdata[2][3],"\t",Forest.Incdata[2][4],"\t",Forest.Incdata[2][5],"\t",Forest.Incdata[2][6]

,"\t",after.getTime()-temp,"\t",relativeGap,"\t",tg,"\t",Forest.ALPHA[alp]);
//writeln(iter_s," ",iter_sce," ",iter_omeg," ",iter_alph);


       }      
    else {
      writeln("No solution!");
      break;
    }
//   if ( !basis.getVectors(cplex) ) {
//      writeln("warm start preparation failed: ",basis.status);
   //} else {
      //writeln("warm start preparation successful ");
   //}
	
    // prepare next iteration




//} } 
} 
}}}	
}
 
  //	basis.end()
  ofile.close();

  if ( Forest!=thisOplModel ) {
    Forest.end();
  }

  status;
}

 
 
			
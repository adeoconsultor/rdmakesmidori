#INCLUDE "Protheus.ch"        
#INCLUDE "topconn.ch"

//--------------------------
User Function MACTBR04()
//--------------------------
Local nIII := 0
Local cQuery := ""          
Private cPerg := PADR("MACTB04",10)

if !SX1->(dbSeek(cPerg))
//Cria as perguntas
	ValidPerg(cPerg)
endif 

Pergunte(cPerg,.T.)       

//Arquivo temporario da funcao para geracao do relatorio
aCTB	:= {}
AADD(aCTB,{"FILIAL" 	    , "C", 02, 0 } )
AADD(aCTB,{"PRODUTO" 	    , "C", 15, 0 } )
AADD(aCTB,{"DESCRI" 	    , "C", 40, 0 } )
AADD(aCTB,{"UM"		 	    , "C", 10, 0 } )
AADD(aCTB,{"GRUPO" 	    	, "C", 04, 0 } )
AADD(aCTB,{"CTBQTD" 	    , "N", 15, 3 } )
AADD(aCTB,{"CTBUNIT" 	    , "N", 15, 3 } )
AADD(aCTB,{"CTBCST" 	    , "N", 15, 3 } )
ctrbCTB := CriaTrab(aCTB, .T.)
dbUseArea(.T.,,ctrbCTB,"CTB",.F.,.F.)
INDEX ON FILIAL + GRUPO + PRODUTO TO &ctrbCTB
//rotina para extra�ao de dados 

//Mensagem solciitando ao usuario que aguarde a extra�ao dos dados
CursorWait()
MsgRun( "Selecionando Movimentos de produ��o, Aguarde...",, { || MCTR04() } ) 
CursorArrow()

CTB->(dbgotop())

If TRepInUse()
	//Gera as definicoes do relatorio
	oReport := ReportDef()
	//Monta interface com o usu�rio
	oReport:PrintDialog()
endif
//Retorno da funcao 

CTB->(dbCloseArea())
Ferase(ctrbCTB+".dbf")
Ferase(ctrbCTB+".cdx")

Return()

//-------------------------
Static Function ReportDef()
//-------------------------
//Variaveis locais da funcao
Local oReport 	:= ""
Local oBreak	:= ""
Local oSection1	:= ""
//Inicio da funcao
//Monta o objeto do relatorio
oReport := TReport():New(cPerg,"Kardex por Grupo de Produto",cPerg,{|oReport| Printreport(oReport)},;
				"Kardex por Grupo de Produto, solicitado pela Elisabeth da contabilidade. ")
//Cria a Se��o do relatorio
oSection1 := TRSection():New(oReport,"Section ?????",{"CTB"},/*Ordem*/)

//Cria as celulas do relat�rio 
TRCell():New(oSection1,"FILIAL"		,"CTB","Filial"   		,"@!"				,05,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"PRODUTO"	,"CTB","Produto"   		,"@!"				,20,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"UM"			,"CTB","U.Medida"   	,"@!"				,20,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"DESCRI"		,"CTB","Descri��o"  	,"@!"				,30,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"GRUPO"		,"CTB","Grupo"   		,"@!"				,10,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"CTBQTD"		,"CTB","Quantidade" 	,"@E 999,999.999"	,15,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"CTBUNIT"	,"CTB","Custo Medio"	,TM(0,17)			, 18,/*lPixel*/,/*CodeBlock*/)                                                                                                                                                                                                                                             //"VALOR A PAGAR"
//TRCell():New(oSection1,"CTBUNIT"	,"CTB","Custo Medio" 	,"@E 999,999.999" 	,15,/*TAMPIXEL*/,/*BLOCO*/)
TRCell():New(oSection1,"CTBCST"		,"CTB","Custo Total" 	,"@E 999,999.999"	,15,/*TAMPIXEL*/,/*BLOCO*/)
Return(oReport)

//-------------------------
Static Function PrintReport()
//-------------------------
Private oSection1 := oReport:Section(1)
oReport:FatLine()
oSection1:Print()
Return()


//-----------------------
Static Function Mctr04()
//-----------------------
//Rotina de pesquisa de dados
//Filial | Produto| Descri��o Prod| Grupo  | Custo Total Baixado por produto
BeginSql Alias "TMP"
	%NoParser%
	SELECT D3_FILIAL,D3_GRUPO,D3_COD, D3_UM,B1_DESC,D3_QUANT, D3_CUSTO1,D3_DOC, D3_OP, D3_EMISSAO
	FROM %Table:SD3% SD3, %Table:SB1% SB1
	WHERE 
	D3_FILIAL  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	D3_GRUPO   BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND 
	D3_EMISSAO BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND 
	D3_TM  IN('999') AND   
	D3_DOC <> 'INVENT' AND   
	D3_COD = B1_COD AND  
	SD3.%NotDel% AND
	SB1.%NotDel% 
	GROUP BY D3_FILIAL,D3_GRUPO,D3_COD, D3_UM,B1_DESC,D3_QUANT, D3_CUSTO1,D3_DOC, D3_OP, D3_EMISSAO 
	ORDER BY D3_FILIAL, D3_COD ,D3_GRUPO 
EndSql

do while TMP->(!eof())
	if CTB->(dbSeek(TMP->D3_FILIAL + TMP->D3_GRUPO + TMP->D3_COD))
		Reclock("CTB",.F.)
		CTB->CTBQTD  	:= CTB->CTBQTD + TMP->D3_QUANT
		CTB->CTBUNIT 	:= Round((TMP->D3_CUSTO1/	TMP->D3_QUANT),3)
		CTB->CTBCST 	:= CTB->CTBCST + TMP->D3_CUSTO1
		Msunlock("CTB")
	else
		Reclock("CTB",.T.)
		CTB->FILIAL   := TMP->D3_FILIAL
		CTB->PRODUTO  := TMP->D3_COD
		CTB->DESCRI   := TMP->B1_DESC
		CTB->UM	 	  := TMP->D3_UM
		CTB->GRUPO    := TMP->D3_GRUPO
		CTB->CTBQTD   := TMP->D3_QUANT
		CTB->CTBUNIT  := Round((TMP->D3_CUSTO1/TMP->D3_QUANT),3)
		CTB->CTBCST   := TMP->D3_CUSTO1
		Msunlock("CTB")
	endif 
	TMP->(dbSkip())
enddo 
TMP->(dbCloseArea())
Return




//--------------------------------
Static Function ValidPerg(cPerg)
//--------------------------------
//Variaveis locais
Local aRegs := {}
Local i,j
//Inicio da funcao
dbSelectArea("SX1")
dbSetOrder(1)
//   1          2        3         4          5           6       7       8             9        10      11     12       13        14        15         16       17       18       19        20          21        22      23        24       25         26        27       28       29       30          31        32       33       34        35          36        37     38     39       40       41        42
//X1_GRUPO/X1_ORDEM/X1_PERGUNT/X1_PERSPA/X1_PERENG/X1_VARIAVL/X1_TIPO/X1_TAMANHO/X1_DECIMAL/X1_PRESEL/X1_GSC/X1_VALID/X1_VAR01/X1_DEF01/X1_DEFSPA1/X1_DEFENG1/X1_CNT01/X1_VAR02/X1_DEF02/X1_DEFSPA2/X1_DEFENG2/X1_CNT02/X1_VAR03/X1_DEF03/X1_DEFSPA3/X1_DEFENG3/X1_CNT03/X1_VAR04/X1_DEF04/X1_DEFSPA4/X1_DEFENG4/X1_CNT04/X1_VAR05/X1_DEF05/X1_DEFSPA5/X1_DEFENG5/X1_CNT05/X1_F3/X1_PYME/X1_GRPSXG/X1_HELP/X1_PICTURE
/*PutSx1(cPerg,"01","De Filial" 		,"","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"02","Ate Filial"		,"","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"03","De Grupo" 		,"","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","")
PutSx1(cPerg,"04","Ate Grupo" 		,"","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","")
PutSx1(cPerg,"05","De Data Op"  	,"","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"06","Ate Data Op" 	,"","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
*/
AADD(aRegs,{cPerg,"01","De Filial" 		,"","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate Filial"		,"","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","De Grupo" 		,"","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"04","Ate Grupo" 		,"","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","",""})
AADD(aRegs,{cPerg,"05","De Data Op"  	,"","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Ate Data Op" 	,"","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//Loop de armazenamento

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			endif
		Next
		MsUnlock()
	endif
Next

Return()
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#DEFINE          cEol         CHR(13)+CHR(10)
#DEFINE          cSep         ";"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPAMNPP2  � Autor � Prima Info         � Data �  24/04/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Gera Planilha excel Head Count CCusto                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10 - Atlantica Midori                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function GPAMNPP2

Private cString, cPerg, oGeraTxt
Private _cFiltroRA

cPerg       := "GPAMNPP2"
CriaSx1(cPerg)

Pergunte(cPerg, .F.)
dbSelectArea("SRA")
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������
DEFINE MSDIALOG oGeraTxt FROM  200,001 TO 410,480 TITLE OemToAnsi( "Head Count CCusto" ) PIXEL

@ 002, 010 TO 095, 230 OF oGeraTxt  PIXEL

@ 010, 018 SAY " Este programa ira gerar o arquivo integrado ao Excel da       " SIZE 200, 007 OF oGeraTxt PIXEL
@ 018, 018 SAY " Planilha Head Count, Centro de Custo.                         " SIZE 200, 007 OF oGeraTxt PIXEL
@ 026, 018 SAY " Conforme parametros selecionados pelo usuario.                " SIZE 200, 007 OF oGeraTxt PIXEL

DEFINE SBUTTON FROM 070,098 TYPE 5 ENABLE OF oGeraTxt ACTION (fFiltro())
DEFINE SBUTTON FROM 070,128 TYPE 5 ENABLE OF oGeraTxt ACTION (Pergunte(cPerg,.T.))
DEFINE SBUTTON FROM 070,158 TYPE 1 ENABLE OF oGeraTxt ACTION (OkGeraTxt(),oGeraTxt:End())
DEFINE SBUTTON FROM 070,188 TYPE 2 ENABLE OF oGeraTxt ACTION (oGeraTxt:End())

ACTIVATE MSDIALOG oGeraTxt Centered

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �OKGERATXT � Autor � AP5 IDE            � Data �  28/12/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa a geracao do arquivo texto.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function OkGeraTxt
Processa({|| RunCont() },"Processando...")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RunCont  � Autor � AP5 IDE            � Data �  17/03/02   ���
�������������������������������������������������������������������������͹��
���Descri��o �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� /*/
Static Function RunCont

Local lSetCentury := __SetCentury( "on" )
Local cDirDocs    := MsDocPath()
Local cPath       := AllTrim( GetTempPath() )
Local oExcelApp
Local cLin, nTotReg, nContReg
Local cNomeArq
Local aInfo	      := {}
Local cFilAnt     := "@@"
Local cUTAnt      := "@@"
Local cDescFil    := ""
Local cDescUT     := ""
Local aPrint      := {}
Local TOT_FIL     := TOT_GERF := TOT_UD := TOT_GERU := 0
Private nHdl
Private cMatDe,cMatAte,dDtInic,dDtFim,cCatFolh,nTpRel

Pergunte(cPerg,.F.)

dDtInic    := Substr(DtoS(mv_par01),1,6)+"01"
dDtFim     := Substr(DtoS(mv_par01),1,6)+StrZero(f_UltDia(mv_par01),2)
cMatDe     := mv_par02
cMatAte    := mv_par03
cCatFolh   := StrTran(MV_PAR04,"*","")
nTpRel     := mv_par05

// Cria Arquivo Texto
MsAguarde( {|| fMtaQuery()}, "Processando...", "Selecao de Registros" )

If Select( "SRANPP2" ) == 0
	Return
EndIf

cNomeArq  := CriaTrab(,.F.) + ".CSV"

nHdl := fCreate( cDirDocs + "\" + cNomeArq )

If nHdl == -1
	MsgAlert("O arquivo de nome "+cNomeArq+" nao pode ser executado! Verifique os parametros.","Atencao!")
	Return
EndIf

//Grava cabe�alho da planilha
fGrvCab()

nTotReg  := 1
nContReg := 1
dbSelectArea( "SRANPP2" )
nTotReg := fLastReg( 8 )
dbGoTop()
ProcRegua( nTotReg )

//tratamento por Filial
If nTpRel == 1 
	
	While !SRANPP2->(Eof())
		
		IncProc( "Processando: "+StrZero(nContReg,6)+" de "+StrZero(nTotReg,6))
		nContReg++
		
		If SRANPP2->RC_FILIAL # cFilAnt
			If fInfo(@aInfo,SRANPP2->RC_FILIAL)
				cDescFil := aInfo[01]
			EndIf
			cFilAnt  := SRANPP2->RC_FILIAL
		EndIf
		
		cLin := SRANPP2->RC_FILIAL + cSep
		cLin += cDescFil + cSep
		cLin += SRANPP2->CTT_CUSTO + cSep
		cLin += SRANPP2->CTT_DESC01 + cSep
		cLin += StrZero(SRANPP2->QTDE,4) + cSep
		cLin += cEol
		
		TOT_FIL  += SRANPP2->QTDE
		TOT_GERF += SRANPP2->QTDE
		
		fGravaTxt( cLin )
		
		SRANPP2->(dbSkip())
		
		If SRANPP2->RC_FILIAL <> cFilAnt
			
			cLin := cFilAnt + cSep
			cLin += cDescFil + cSep
			cLin += "" + cSep
			cLin += "" + cSep
			cLin += StrZero(TOT_FIL,4) + cSep
			cLin += cEol
			
			fGravaTxt( cLin )
			
			TOT_FIL  := 0
			
		EndIf
		
	EndDo
	
	If TOT_FIL > 0
		cLin := cFilAnt + cSep
		cLin += cDescFil + cSep
		cLin += "" + cSep
		cLin += "" + cSep
		cLin += StrZero(TOT_FIL,4) + cSep
		cLin += cEol
		TOT_FIL  := 0
		fGravaTxt( cLin )
	EndIf
	
	If TOT_GERF > 0
		cLin := "" + cSep
		cLin += "Total Geral" + cSep
		cLin += "" + cSep
		cLin += "" + cSep
		cLin += StrZero(TOT_GERF,4) + cSep
		cLin += cEol
		TOT_GERF := 0
		fGravaTxt( cLin )
	EndIf
	
//tratamento por Unidade de Trabalho	
ElseIf nTpRel == 2
	
	While !SRANPP2->(Eof())
		
		IncProc( "Processando: "+StrZero(nContReg,6)+" de "+StrZero(nTotReg,6))
		nContReg++
		
		If SRANPP2->RC_ITEM # cUtAnt
			If fInfo(@aInfo,SRANPP2->RC_ITEM)
				cDescUT := aInfo[01]
			EndIf
			cUTAnt  := SRANPP2->RC_ITEM
		EndIf
		
		cLin := SRANPP2->RC_ITEM + cSep
		cLin += cDescUT + cSep
		cLin += SRANPP2->CTT_CUSTO + cSep
		cLin += SRANPP2->CTT_DESC01 + cSep
		cLin += StrZero(SRANPP2->QTDE,4) + cSep
		cLin += cEol
		
		TOT_UD += SRANPP2->QTDE
		TOT_GERU += SRANPP2->QTDE
		
		fGravaTxt( cLin )
		
		SRANPP2->(dbSkip())
		
		If SRANPP2->RC_ITEM <> cUTAnt
			
			cLin := cUTAnt + cSep
			cLin += cDescUT + cSep
			cLin += "" + cSep
			cLin += "" + cSep
			cLin += StrZero(TOT_UD,4) + cSep
			cLin += cEol
			
			fGravaTxt( cLin )
			
			TOT_UD  := 0
			
		EndIf
		
	EndDo
	
	If TOT_UD > 0
		cLin := cUTAnt + cSep
		cLin += cDescUT + cSep
		cLin += "" + cSep
		cLin += "" + cSep
		cLin += StrZero(TOT_UD,4) + cSep
		cLin += cEol
		TOT_UD  := 0
		fGravaTxt( cLin )
	EndIf
	
	If TOT_GERU > 0
		cLin := "" + cSep
		cLin += "Total Geral" + cSep
		cLin += "" + cSep
		cLin += "" + cSep
		cLin += StrZero(TOT_GERU,4) + cSep
		cLin += cEol
		TOT_GERU := 0
		fGravaTxt( cLin )
	EndIf
	
//tratamento por Filial e Unidade de Trabalho 
Else
	
	While !SRANPP2->(Eof())
		
		IncProc( "Processando: "+StrZero(nContReg,6)+" de "+StrZero(nTotReg,6))
		nContReg++
		
		If SRANPP2->RC_FILIAL # cFilAnt
			If fInfo(@aInfo,SRANPP2->RC_FILIAL)
				cDescFil := aInfo[01]
			EndIf
			cFilAnt  := SRANPP2->RC_FILIAL
		EndIf
		
		If SRANPP2->RC_ITEM # cUtAnt
			If fInfo(@aInfo,SRANPP2->RC_ITEM)
				cDescUT := aInfo[01]
			EndIf
			cUTAnt  := SRANPP2->RC_ITEM
		EndIf
		
		cLin := SRANPP2->RC_FILIAL + cSep
		cLin += cDescFil + cSep
		cLin += SRANPP2->RC_ITEM + cSep
		cLin += cDescUT + cSep
		cLin += SRANPP2->CTT_CUSTO + cSep
		cLin += SRANPP2->CTT_DESC01 + cSep
		cLin += StrZero(SRANPP2->QTDE,4) + cSep
		cLin += cEol
		
		TOT_FIL  += SRANPP2->QTDE
		TOT_GERF += SRANPP2->QTDE
		TOT_UD   += SRANPP2->QTDE
		TOT_GERU += SRANPP2->QTDE
		
		fGravaTxt( cLin )
		
		SRANPP2->(dbSkip())
		
		If SRANPP2->RC_FILIAL == cFilAnt .And. SRANPP2->RC_ITEM <> cUTAnt
			
			cLin := cFilAnt  + cSep
			cLin += cDescFil + cSep
			cLin += cUTAnt   + cSep
			cLin += cDescUT  + cSep
			cLin += ""       + cSep
			cLin += ""       + cSep
			cLin += StrZero(TOT_UD,4) + cSep
			cLin += cEol
			
			fGravaTxt( cLin )
			
			TOT_UD := 0
			
		EndIf
		
		If SRANPP2->RC_FILIAL <> cFilAnt
			
			cLin := cFilAnt  + cSep
			cLin += cDescFil + cSep
			cLin += ""       + cSep
			cLin += ""       + cSep
			cLin += ""       + cSep
			cLin += ""       + cSep
			cLin += StrZero(TOT_FIL,4) + cSep
			cLin += cEol
			
			fGravaTxt( cLin )
			
			TOT_FIL := 0
			
		EndIf
		
	EndDo
	
	If TOT_UD > 0
		cLin := cFilAnt  + cSep
		cLin += cDescFil + cSep
		cLin += cUTAnt   + cSep
		cLin += cDescUT  + cSep
		cLin += ""       + cSep
		cLin += ""       + cSep
		cLin += StrZero(TOT_UD,4) + cSep
		cLin += cEol
		
		fGravaTxt( cLin )
		
		TOT_UD := 0
	EndIf
	
	If TOT_FIL > 0
		cLin := cFilAnt  + cSep
		cLin += cDescFil + cSep
		cLin += ""       + cSep
		cLin += ""       + cSep
		cLin += ""       + cSep
		cLin += ""       + cSep
		cLin += StrZero(TOT_FIL,4) + cSep
		cLin += cEol
		
		fGravaTxt( cLin )
		
		TOT_FIL := 0
	EndIf
	
	If TOT_FIL > 0
		cLin := "" + cSep
		cLin += "Total Geral" + cSep
		cLin += "" + cSep
		cLin += "" + cSep
		cLin += StrZero(TOT_FIL,4) + cSep
		cLin += cEol
		fGravaTxt( cLin )
	EndIf
	
EndIf

SRANPP2->(dbCloseArea())

fClose( nHdl )

MsAguarde( {|| fStartExcel( cDirDocs, cNomeArq, cPath )}, "Aguarde...", "Integrando Planilha ao Excel..." )

If !lSetCentury
	__SetCentury( "off" )
EndIf

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �fStartExcel�Autor  �PrimaInfo           � Data �  15/04/09   ���
��������������������������������������������������������������������������͹��
���Desc.     �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � Para uso do programa principal	                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������ */
Static Function fStartExcel( cDirDocs, cNomeArq, cPath )

CpyS2T( cDirDocs + "\" + cNomeArq , cPath, .T. )

If !ApOleClient( 'MsExcel' )
	MsgAlert( 'MsExcel nao instalado' )
Else
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( cPath+cNomeArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fMtaQuery �Autor  �PrimaInfo           � Data �  24/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Programa Princiapal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fMtaQuery()

Local cQuery   := ""
Local cArqMvto := ""

If Substr(Dtos(mv_par01),1,6) == GetMv("MV_FOLMES")
	cArqMvto := RetSqlName( "SRC" )
Else
	cArqMvto := "RC"+cEmpAnt+Substr(Dtos(mv_par01),3,4)
EndIf

If nTpRel == 1 //Trata subquery quando a selecao for por filial
	
	cQuery := "SELECT RC_FILIAL,CTT_CUSTO,CTT_DESC01,COUNT(1) as QTDE"
	cQuery += "  FROM " + RetSqlName( "SRA" ) + " RA," +RetSqlName( "CTT" ) + " CTT,"+ cArqMvto + " RC"
	cQuery += " WHERE RA.D_E_L_E_T_ <>'*'"
	cQuery += "   AND CTT.D_E_L_E_T_ <>'*'"
	cQuery += "   AND RC.D_E_L_E_T_ <>'*'"
	cQuery += "   AND RC_CC = CTT_CUSTO"
	cQuery += "   AND RA_FILIAL = RC_FILIAL"
	cQuery += "   AND RA_MAT = RC_MAT"
	cQuery += "   AND RC_PD ='890'"
	cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	If !Empty(_cFiltroRA)
		cQuery += "   AND ("+_cFiltroRA+")"
	Endif
	cQuery += "   AND RA_CATFUNC LIKE'["+cCatFolh+"]'"
	cQuery += "   AND (RA_DEMISSA = '' OR RA_DEMISSA > '"+ dDtFim +"')"
	cQuery += " GROUP BY RC_FILIAL,CTT_CUSTO,CTT_DESC01"
	cQuery += " ORDER BY RC_FILIAL,CTT_CUSTO,CTT_DESC01"
	
ElseIf nTpRel == 2  //Trata subquery quando a selecao for por unid Trabalho
	
	cQuery += "SELECT RC_ITEM,CTT_CUSTO,CTT_DESC01,COUNT(1) as QTDE"
	cQuery += "  FROM " + RetSqlName( "SRA" ) + " RA," +RetSqlName( "CTT" ) + " CTT,"+ cArqMvto + " RC"
	cQuery += " WHERE RA.D_E_L_E_T_ <>'*'"
	cQuery += "   AND CTT.D_E_L_E_T_ <>'*'"
	cQuery += "   AND RC.D_E_L_E_T_ <>'*'"
	cQuery += "   AND RC_CC = CTT_CUSTO"
	cQuery += "   AND RA_FILIAL = RC_FILIAL"
	cQuery += "   AND RA_MAT = RC_MAT"
	cQuery += "   AND RC_PD ='890'"
	cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	If !Empty(_cFiltroRA)
		cQuery += "   AND ("+_cFiltroRA+")"
	Endif
	cQuery += "   AND RA_CATFUNC LIKE'["+cCatFolh+"]'"
	cQuery += "   AND (RA_DEMISSA = '' OR RA_DEMISSA > '"+ dDtFim +"')"
	cQuery += " GROUP BY RC_ITEM,CTT_CUSTO,CTT_DESC01"
	cQuery += " ORDER BY RC_ITEM,CTT_CUSTO,CTT_DESC01"
	
Else //Trata subquery quando a selecao for por filial + unid Trabalho
	
	cQuery += "SELECT RC_FILIAL,RC_ITEM,CTT_CUSTO,CTT_DESC01,COUNT(1) as QTDE"
	cQuery += "  FROM " + RetSqlName( "SRA" ) + " RA," +RetSqlName( "CTT" ) + " CTT,"+ cArqMvto + " RC"
	cQuery += " WHERE RA.D_E_L_E_T_ <>'*'"
	cQuery += "   AND CTT.D_E_L_E_T_ <>'*'"
	cQuery += "   AND RC.D_E_L_E_T_ <>'*'"
	cQuery += "   AND RC_CC = CTT_CUSTO"
	cQuery += "   AND RA_FILIAL = RC_FILIAL"
	cQuery += "   AND RA_MAT = RC_MAT"
	cQuery += "   AND RC_PD ='890'"
	cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	If !Empty(_cFiltroRA)
		cQuery += "   AND ("+_cFiltroRA+")"
	Endif
	cQuery += "   AND RA_CATFUNC LIKE'["+cCatFolh+"]'"
	cQuery += "   AND (RA_DEMISSA = '' OR RA_DEMISSA > '"+ dDtFim +"')"
	cQuery += " GROUP BY RC_FILIAL,RC_ITEM,CTT_CUSTO,CTT_DESC01"
	cQuery += " ORDER BY RC_FILIAL,RC_ITEM,CTT_CUSTO,CTT_DESC01"
	
EndIf

TCQuery cQuery New Alias "SRANPP2"

TcSetField( "SRANPP2", "QTDE"  , "N", 4, 0 )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGrvCab   �Autor  �PrimaInfo           � Data �  24/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Para uso do programa principal                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */
Static Function fGrvCab()

Local cLin := ""

//Trata Por Filial
If nTpRel == 1
	cLin := "FILIAL" + cSep
	cLin += "DESC_FILIAL" + cSep
	cLin += "CENTRO DE CUSTO" + cSep
	cLin += "DESC_CCUSTO" + cSep
	cLin += "QUANTIDADE" + cSep
//Trata Por Unidade de trabalho
ElseIf nTpRel == 2
	cLin := "UNID_TRAB" + cSep
	cLin += "DESC_UT" + cSep
	cLin += "CENTRO DE CUSTO" + cSep
	cLin += "DESC_CCUSTO" + cSep
	cLin += "QUANTIDADE" + cSep
//Trata Por Filial e Unidade de trabalho
Else
	cLin := "FILIAL" + cSep
	cLin += "DESC_FILIAL" + cSep
	cLin += "UN TRABALHO" + cSep
	cLin += "DESC_UT" + cSep
	cLin += "CENTRO DE CUSTO" + cSep
	cLin += "DESC_CCUSTO" + cSep
	cLin += "QUANTIDADE" + cSep
EndIf

cLin += cEol

fGravaTxt( cLin )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fFiltro  �Autor  �Microsiga           � Data �  12/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Para uso do Programa princial                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */

Static Function fFiltro

_cFiltroRA := BuildExpr("SRA",,_cFiltroRA,.T.)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGravaTxt �Autor  �PrimaInfo           � Data �  24/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Para uso do programa principal                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */
Static Function fGravaTxt( cLin )

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
		Return
	Endif
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLastReg  �Autor  �PrimaInfo           � Data �  24/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Uso do programa principal                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */
Static Function fLastReg( nSkip )

Local nReg := 0

dbGoTop()
Do While !Eof()
	dbSkip( nSkip )
	If !Eof()
		nReg := Recno()
	EndIf
EndDo
dbGoTop()

Return( nReg )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaSX1   � Autor � PrimaInfo          � Data �  24/04/10   ���
�������������������������������������������������������������������������͹��
���Descricao �Objetivo desta funcao e verificar se existe o grupo de      ���
���          �perguntas, se nao existir a funcao ira cria-lo.             ���
�������������������������������������������������������������������������͹��
���Uso       �cPerg -> Nome com  grupo de perguntas em quest�o.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function CriaSx1(cPerg)

Local aHelp := {}

PutSx1(cPerg,"01","Data Base ?"          ,"","","mv_ch1","D",08,00,00,"G","naovazio"  ,""   ,"","","mv_par01",""        ,"","","",""          ,"","",""       ,"","","","","","","","","","","","")
PutSx1(cPerg,"02","Matricula De ? "      ,"","","mv_ch2","C",06,00,00,"G",""          ,"SRA","","","mv_par02",""        ,"","","",""          ,"","",""       ,"","","","","","","","","","","","")
PutSx1(cPerg,"03","Matricula At� ?"      ,"","","mv_ch3","C",06,00,00,"G",""          ,"SRA","","","mv_par03",""        ,"","","",""          ,"","",""       ,"","","","","","","","","","","","")
PutSx1(cPerg,"04","Categoria ?"          ,"","","mv_ch4","C",15,00,00,"G","fCategoria",""   ,"","","mv_par04",""        ,"","","",""          ,"","",""       ,"","","","","","","","","","","","")
PutSx1(cPerg,"05","Trata ?"              ,"","","mv_ch5","N",01,00,00,"C",""          ,""   ,"","","mv_par05","1-Filial","","","","2-UnidTrab","","","3-Ambos","","","","","","","","","","","","")

Return Nil

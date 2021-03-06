#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Impcopart �Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     � 									                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ImpCoPart()

//��������������������������������������������������������Ŀ
//�Declaracao de variaveis                                 �
//����������������������������������������������������������
Local oWizard
Local nMetGlob
Local nMetParc
Local oRadioArq
Local nRadioArq		:= 1

Local cText
Local cFile			:= replicate( " ", 80 )
Local cHeader 		:= "Importa��o de dados"
Local cTpArq		:= "Delimitado (*.csv)|*.CSV|"
Local cDelim		:= AllTrim(SuperGetMV("MV_TPDELI",.F.,';'))
Local nLinCabec		:= 1 // Padr�o sem linha de cabe�alho
Local cCabec		:= "" // String com o cabe�alho do arquivo original, se houver
Local nQtdCab		:= 1 // String com o cabe�alho do arquivo original, se houver
Local cNmAlias		:= "Co-Participa��o (RHO)"
Local cTipo			:= "1"

Private INCLUI	:= .T.
Private ALTERA	:= .F.

cText 	:= 	 "Esta rotina tem por objetivo importar registros, atrav�s " + ; 
			 "de um arquivo padr�o CSV (delimitado) , e armazena-los na tabela "+ ; 
			 "correspondente aos valores de co-participa��o dos planos de sa�de."+ CRLF + ; 
			 "Os nomes das colunas devem ser os mesmos nomes de campos a serem atualizados."+ CRLF + CRLF + ; 
			 "Ao final da importa��o ser� gerado um arquivo de log contendo as "+ ; 
			 "inconsist�ncias."

	//�������������������������������Ŀ
	//�Primeiro Painel - Abertura     �
	//���������������������������������
	DEFINE WIZARD oWizard 	TITLE "Importa��o de dados" ;
							HEADER cHeader ; 
							MESSAGE "Apresenta��o." ;
							TEXT cText ;
							NEXT { || .T. } ;
							FINISH {|| .T.} PANEL
	
	//������������������������������������Ŀ
	//�Segundo Painel - Arquivo e Contrato �
	//��������������������������������������
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Selecione os tabela que deseja importar" ;
							BACK {|| .T. } ;
							NEXT {|| .T. } ;
							FINISH {|| .F. } ;
							PANEL         
	
	oPanel := oWizard:GetPanel( 2 )
	
	@ 15, 08 GROUP oGrpCon 	TO 120, 230 LABEL "Cadastro a ser importado" OF oPanel PIXEL DESIGN
	     
	@ 25,35 Radio oRadioArq Var nRadioArq Items "Co-Participa��o Planos de Sa�de (RHO)";
												3D 	Size 170,10 Of oPanel PIXEL DESIGN ;
												ON CHANGE ImpChgRadio(nRadioArq,@cNmAlias)

	//������������������������������������Ŀ
	//�Segundo Painel - Arquivo e Contrato �
	//��������������������������������������
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Selecione o arquivo para importa��o." ;
							BACK {|| .T. } ;
							NEXT {|| ! empty( cDelim ) .and. ! empty( cFile ) } ;
							FINISH {|| .F. } ;
							PANEL         
	
	oPanel := oWizard:GetPanel( 3 )
	
	@ 10, 08 GROUP oGrpCon 	TO 40, 280 LABEL "Selecione um arquivo." ; 
							OF oPanel ;
							PIXEL ;
	     					DESIGN

	@ 20, 15 MSGET oArq 	VAR cFile WHEN .F. OF oPanel SIZE 140, 10 PIXEL ;
							MESSAGE "Utilize o bot�o ao lado para selecionar" ; 

	DEFINE SBUTTON oButArq 	FROM 21, 160 ;
					 		TYPE 14 ;
					 		ACTION cFile := cGetFile(cTpArq, , 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) ; 
					 		OF oPanel ;
					 		ENABLE
	
	@ 50, 08 GROUP oGrpCon 	TO 130, 280 LABEL "Informe as configura��es do arquivo." ; 
							OF oPanel ;
							PIXEL ;
	     					DESIGN
	     
  	@ 60,20 SAY "Delimitador" OF oPanel SIZE 35,8 PIXEL   
	@ 60,60 MSGET oDelim	VAR cDelim  ;
							PICTURE "@!" ;
							VALID !empty(cDelim) ;
							MESSAGE "Informe um delimitador de campo." ; 
							OF oPanel SIZE 10,8 PIXEL 
                         	
  	@ 80,20 SAY "Tipo" OF oPanel SIZE 35,8 PIXEL   
	@ 80,60 COMBOBOX oTipo  Var cTipo ITEMS {"1=Somente Log","2=Log + Importa��o"} 	SIZE 200,010 OF oPanel PIXEL  

	//�����������������������������������������������Ŀ
	//�Terceiro Painel - Confirmacao  / Processamento �
	//�������������������������������������������������
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Confirma��o dos dados e in�cio de processamento." ; 
							BACK {|| .T. } ;
							NEXT {|| .T. } ;
							FINISH {|| .F. } ;
							PANEL         
							
	oPanel := oWizard:GetPanel( 4 )

	@ 010, 010 SAY "Arquivo" OF oPanel SIZE 140, 8 PIXEL   
	@ 010, 050 SAY cFile  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL  
	
	@ 030, 010 SAY  "Delimitador" OF oPanel SIZE 140, 8 PIXEL   
	@ 030, 050 SAY  cDelim  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	


	@ 050, 010 SAY  "Alias" OF oPanel SIZE 140, 8 PIXEL   
	@ 050, 050 SAY  cNmAlias  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	


	@ 070, 010 SAY  "Tipo Proc.:" OF oPanel SIZE 140, 8 PIXEL   
	@ 070, 050 SAY  IIf(cTipo=="1","Somente Log","Log+Importa��o")  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	
                                      

	//�����������������������������������������������Ŀ
	//�Quarto Painel - Processamento                  �
	//�������������������������������������������������
	CREATE PANEL oWizard 	HEADER cHeader ;
							MESSAGE "Processamento da Importa��o." ; 
							BACK {|| .F. } ;
							NEXT {|| .T. } ;
							FINISH {|| .T. } ;
							EXEC {|| CursorWait(), IMPCADPro( oMetGlob, nRadioArq, cFile, cDelim, cTipo ), CursorArrow() } ;
							PANEL 
							        
	oPanel := oWizard:GetPanel( 5 )

	@ 25, 30 SAY "Importa��o" OF oPanel SIZE 140, 8 PIXEL   
	@ 40, 30 METER oMetGlob 	VAR nMetGlob ;
								TOTAL 100 ;
								SIZE 224,10 OF oPanel PIXEL UPDATE DESIGN ;
								BARCOLOR CLR_BLACK,CLR_WHITE ;
								COLOR CLR_WHITE,CLR_BLACK ;
							 	NOPERCENTAGE 

	
ACTIVATE WIZARD oWizard CENTER

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMPCADPro �Autor  �Willer Trindade Nery   � Data �  23/07/14 ��
�������������������������������������������������������������������������͹��
���Desc.     �Importacao do arquivo selecionado                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function IMPCADPro( oMetGlob, nRadioArq, cFile, cDelim,cTipo )

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local aArea		:= GetArea()
Local lFirst	:= .T.
Local cLinha 	:= ""
Local aHeader	:= {}
Local nHdl    	:= 	0
Local cEnvServ	:= GetEnvServer()
Local cIniFile	:= GetADV97()
Local cEnd		:= GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
Local cDtHr 	:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
Local cPath		:= "\IMPORT\"
Local cTipoLog	:= "Import_"
Local cNomeLog	:=	cPath+cTipoLog+cDtHr+"_Log.txt"
Local cArq		:=	cEnd+cNomeLog              
Local cLin		:= ""   
Local cCdAlias	:= ""
Local nQtReg	:= 0
Local nQtNOk	:= 0
Local nQtOk		:= 0
Local aLog		:= {}
Local lGrava	:= (cTipo == "2")   
Local cRotina	:= ""
Local nCont		:= 0

MAKEDIR(cEnd+cPath)

//�������������������������������������������������Ŀ
//�Validacao do arquivo para importacao             �
//���������������������������������������������������

If !File(cFile) .OR. Empty(cFile)
	ApMsgStop("Problemas com arquivo informado!")
	RestArea(aArea)
	Return
EndIf


//����������������������������������������������������Ŀ
//�Identifica Alias de importacao                      �
//������������������������������������������������������
Do Case
	Case nRadioArq == 1		// "Clientes (SA1)",;
		 cCdAlias	:= "RHO"
		 cRotina		:= "GPEA003"
EndCase



//��������������������������������������Ŀ
//�Inicia Log                            �
//����������������������������������������
AAdd(aLog, Replicate( '=', 80 ) )
AAdd(aLog, 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S' )
AAdd(aLog, Replicate( '-', 80 ) )
AAdd(aLog, 'DATABASE...........: ' + DtoC( dDataBase ) )
AAdd(aLog, 'DATA...............: ' + DtoC( Date() ) )
AAdd(aLog, 'HORA...............: ' + Time() )
AAdd(aLog, 'ENVIRONMENT........: ' + GetEnvServer() )
AAdd(aLog, 'PATCH..............: ' + GetSrvProfString( 'StartPath', '' ) )
AAdd(aLog, 'ROOT...............: ' + GetSrvProfString( 'RootPath', '' ) )
AAdd(aLog, 'VERS�O.............: ' + GetVersao() )
AAdd(aLog, 'M�DULO.............: ' + 'SIGA' + cModulo )
AAdd(aLog, 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL )
AAdd(aLog, 'NOME EMPRESA.......: ' + Capital( Trim( SM0->M0_NOME ) ) )
AAdd(aLog, 'NOME FILIAL........: ' + Capital( Trim( SM0->M0_FILIAL ) ) )
AAdd(aLog, 'USU�RIO............: ' + SubStr( cUsuario, 7, 15 ) )
AAdd(aLog, 'TABELA IMPORT......: ' + cCdAlias )
AAdd(aLog, 'ARQUIVO IMPORT.....: ' + cFile )
AAdd(aLog, 'DELIMITADOR........: ' + cDelim )
AAdd(aLog, 'MODO PROCESSAMENTO.: ' + IIf(lGrava,"Atualizacao","Simulacao") )
AAdd(aLog, Replicate( ':', 80 ) )
AAdd(aLog, '' )

AAdd(aLog, "Import = INICIO - Data "+DtoC(dDataBase)+ " as "+Time() )

//������������������������������������������Ŀ
//�Leitura do arquivo                        �
//��������������������������������������������
FT_FUSE(cFile)
nTot := FT_FLASTREC()
nAtu := 0

oMetGlob:SetTotal(nTot)
CursorWait()     

FT_FGOTOP()
While !FT_FEOF()
	nAtu++
	oMetGlob:Set(nAtu)

	cLinha := LeLinha() //FT_FREADLN()
	
	If Empty(cLinha)
		FT_FSKIP()
		Loop
	EndIf

	//������������������������������������������Ŀ
	//�Tratamento de colunas                     �
	//��������������������������������������������
	aCols := {}
	aCols := TrataCols(cLinha,cDelim)
	If lFirst
		aHeader := aClone(aCols)
		lFirst := .F.

		//�������������������������������������������Ŀ
		//�Valida nomes das colunas                   �
		//���������������������������������������������
		cCpos := ImpVldCols(cCdAlias,aHeader)
		If !Empty(cCpos)
			ApMsgStop("Problemas na estrutura do arquivo, faltam as seguintes colunas "+cCpos)
			Return
		EndIf

	Else

		nQtReg++


		//�����������������������������������������������������Ŀ
		//�Validacao de campos obrigatorios                     �
		//�������������������������������������������������������
		cMsg := ImpObrigat(cCdAlias,aCols,aHeader)
		If !Empty(cMsg)
			AtuLog("NO MOT: CAMPOS OBRIGATORIOS - REGISTRO IGNORADO - "+cMsg,@aLog,nAtu)
			nQtNOk++
			FT_FSKIP()
			Loop
		EndIf
	
	
		//��������������������������������������������������������Ŀ
		//�Chamada de rotina automatica de inclusao                �
		//����������������������������������������������������������
		If lGrava
			aRet := {}
			aRet := ImpGrava(cCdAlias,cRotina,aCols,aHeader)
			If aRet[1]
				nQtOk++
				AtuLog("OK MOT:REGISTRO INCLUIDO"+aRet[2],@aLog,nAtu)
			
			Else
				AtuLog("NO MOT: PROBLEMAS NA GRAVACAO ROTINA AUTOMATICA - "+cRotina+" - "+aRet[2],@aLog,nAtu)
				nQtNOk++
			
			EndIF
		Else
			nQtOk++
			AtuLog("OK MOT:REGISTRO INCLUIDO",@aLog,nAtu)
		EndIf
	EndIf
	
	FT_FSKIP()
End
FT_FUSE()

AAdd(aLog, "Import = Total de Registros = "+ Alltrim(Str(nQtReg)))
AAdd(aLog, "Import = Registros Nao importados = "+ Alltrim(Str(nQtNOk)))
AAdd(aLog, "Import = Registros importados = "+ Alltrim(Str(nQtOk)))


AAdd(aLog, "Import = FIM Data "+DtoC(dDataBase)+ " as "+Time() )

//������������������������������������������������Ŀ
//�Finaliza arquivo de Log                         �
//��������������������������������������������������
nHdl  := 	fCreate(cArq)
If nHdl == -1
	MsgAlert("O arquivo  "+cArq+" nao pode ser criado!","Atencao!")
	fClose(nHdl)
	fErase(cArq)
	RestArea(aArea)
 	Return()
EndIf

For nCont:=1 to Len(aLog)
	
	cLin += aLog[nCont] + CHR(13)+CHR(10)
	
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		fClose(nHdl)
	    fErase(cArq)
	    cLin:=""
		RestArea(aArea)
	    Return()
	EndIf
	
	cLin:=""
Next

fClose(nHdl)

ApMsgInfo("Verifique arquivo de log "+cArq)

RestArea(aArea)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuLog    �Autor  �Willer Trindade Nery   � Data �  23/07/14 ��
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza Array de Log                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AtuLog(cMsg,aLog,nAtu)

AAdd(aLog, " Import = Linha "+StrZero(nAtu,12)+" = "+;
			" LOG = "+cMsg )
Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeLinha   �Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �Tratamento de leitura de linha TXT, principalmente para     ���
���          �casos de ultrapassar 1Kb por linha                          ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LeLinha()
Local cLinhaTmp := ""
Local cLinhaM100 := ""

cLinhaTmp := FT_FReadLN()

If !Empty(cLinhaTmp)
	cIdent:= Substr(cLinhaTmp,1,1)
	If Len(cLinhaTmp) < 1023
		cLinhaM100 := cLinhaTmp
	Else
		cLinAnt := cLinhaTmp
		cLinhaM100 += cLinAnt
		Ft_FSkip()
		cLinProx:= Ft_FReadLN()
		If Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent
			While Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent .and. !Ft_fEof()
				cLinhaM100 += cLinProx
				Ft_FSkip()
				cLinProx := Ft_fReadLn()
				If Len(cLinProx) < 1023 .and. Substr(cLinProx,1,1) <> cIdent
					cLinhaM100 += cLinProx
				Endif
			Enddo
		Else
			cLinhaM100 += cLinProx
		Endif
	Endif
Endif

Return(cLinhaM100)





/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TrataCols �Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna array com as colunas da linha informada             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TrataCols(cLinha,cSep)
Local aRet 		:= {}
Local nPosSep	:= 0


nPosSep	:= At(cSep,cLinha)
While nPosSep <> 0
	AAdd(aRet, SubStr(cLinha,1,nPosSep-1)  )
	cLinha := SubStr(cLinha,nPosSep+1)
 	nPosSep	:= At(cSep,cLinha)
EndDo	
AAdd(aRet, cLinha )
Return aRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetCol    �Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna conteudo de coluna especifica                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetCol(cCpo,aCols,aHeader)
Local cRet 	:= ""
Local nPos	:= 0
Local aSX3Area	:= SX3->(GetArea())

nPos := AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim(cCpo)) })

If !Empty(nPos)
	If Upper(AllTrim(aCols[nPos])) <> "NULL"

		DbSelectArea("SX3")
		DbSetOrder(2)
		If MsSeek(cCpo)
			If SX3->X3_TIPO == "D"
				cRet := StoD(AllTrim(aCols[nPos]))
			ElseIf SX3->X3_TIPO == "N"
				cRet := Val(AllTrim(aCols[nPos]))
			Else
				cRet := PadR(Upper(AllTrim(aCols[nPos])),TamSX3(cCpo)[1])
			EndIf
		Else
			cRet := Upper(AllTrim(aCols[nPos]))
		EndIf
	EndIf
EndIf

SX3->(RestArea(aSX3Area))
Return cRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpVldCols�Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �Analise de colunas obrigatorias para cada alias             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpVldCols(cCdAlias,aHeader)
Local cRet 		:= ""
Local cFilSA1 	:= ""

Do Case
	Case cCdAlias == "SA1"
		
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_LOJA")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_LOJA"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_NOME")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_NOME"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_NREDUZ")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_NREDUZ"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_END")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_END"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_TIPO")) })	== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_TIPO"
		EndIf
		If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_EST")) })		== 0
			cRet += IIf(Empty(cRet),"","/")+"A1_EST"
		EndIf

EndCase

Return cRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpObrigat�Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �Valida preenchimento/conteudo de campos obrigatorios        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpObrigat(cCdAlias,aCols,aHeader)
Local cRet 		:= ""

Do Case
	Case cCdAlias == "SA1"
		If Empty(RetCol("A1_LOJA",aCols,aHeader))
			cRet += " / Coluna A1_LOJA esta vazia! "
		EndIf
		If Empty(RetCol("A1_NOME",aCols,aHeader))
			cRet += " / Coluna A1_NOME esta vazia! "
		EndIf
		If Empty(RetCol("A1_NREDUZ",aCols,aHeader))
			cRet += " / Coluna A1_NREDUZ esta vazia! "
		EndIf
		If Empty(RetCol("A1_END",aCols,aHeader))
			cRet += " / Coluna A1_END esta vazia! "
		EndIf
		If Empty(RetCol("A1_TIPO",aCols,aHeader))
			cRet += " / Coluna A1_TIPO esta vazia! "
		EndIf
		If Empty(RetCol("A1_EST",aCols,aHeader))
			cRet += " / Coluna A1_EST esta vazia! "
		EndIf

EndCase

Return cRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpGrava  �Autor  �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �Chamada da rotina automatica de gravacao                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpGrava(cCdAlias,cRotina,aCols,aHeader)
Local nX			:= 0
Local cRotAuto		:= ""
Local lOk			:= .F.
Local cMsg			:= ""
Local lGeraNumSeq	:= .T.
Local cArqErro		:= "ERRO_AUTO.TXT"
Local lTemFilial	:= .F.
Local cCpoFilial 	:= IIf( SubStr(cCdAlias,1,1) == "S", SubStr(cCdAlias,2,2), cCdAlias) + "_FILIAL"
Local cFilAlias		:= xFilial(cCdAlias)
Private lMsHelpAuto := .T.                                         
Private lMsErroAuto := .F.    
Private aReg		:= {}


//���������������������������������������������������������������Ŀ
//�Monta array com os campos do registro                          �
//�����������������������������������������������������������������
For nX:=1 to Len(aHeader)
	AAdd(aReg, {	Upper(Alltrim(aHeader[nX]))					    ,;
					RetCol(Alltrim(aHeader[nX]),aCols,aHeader)		,;
					Nil} )
Next


//�����������������������������������������������������������������Ŀ
//�Chamada da rotina automatica                                     �
//�������������������������������������������������������������������
DbSelectArea(cCdAlias)

cRotAuto := "MSExecAuto({|x,y| "+cRotina+"(x,y)},aReg,3)"
&cRotAuto

If lMsErroAuto
	MostraErro( GetSrvProfString("Startpath","") , cArqErro )
	cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro )
Else
	lOk := .T.
EndIf

Return {lOk, cMsg }



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpChgRadio�Autor �Willer Trindade Nery   � Data �  23/07/14���
�������������������������������������������������������������������������͹��
���Desc.     �tratamento de mudanca to tipo de arquivo para importacao    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Midori Atlantica                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpChgRadio(nRadioArq,cNmAlias)
Do Case
	Case nRadioArq == 1		
		cNmAlias := "Co-Participa��o Plano de Sa�de (RHO)" 
EndCase

Return